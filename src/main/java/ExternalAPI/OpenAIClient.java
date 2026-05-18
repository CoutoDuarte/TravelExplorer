package ExternalAPI;

import Connection.Classes.CriarSugestaoRequest;
import Connection.Classes.HotelSugestao;
import Connection.Classes.PesquisaRequest;
import Connection.Classes.SugestaoViagem;
import Connection.Classes.VooInfo;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class OpenAIClient {

    private static final int LOG_BODY_MAX = 500;
    private static final int DEBUG_BODY_MAX = 300;
    private static final int FALLBACK_DESC_MAX = 800;
    private static final int DEBUG_TEXT_PREVIEW_MAX = 200;

    private final HttpClient http = buildHttpClient();
    private final IaeduParseDebug lastIaeduDebug = new IaeduParseDebug();

    public static class IaeduParseDebug {
        public int rawLength;
        public String textPreview = "";
    }

    public IaeduParseDebug getLastIaeduDebug() {
        return lastIaeduDebug;
    }

    private static HttpClient buildHttpClient() {
        HttpClient.Builder builder = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(15));
        if (ApiConfig.OPENAI_TRUST_ALL_SSL) {
            builder.sslContext(createTrustAllSslContext());
        }
        return builder.build();
    }

    private static SSLContext createTrustAllSslContext() {
        try {
            TrustManager[] trustAll = new TrustManager[] {
                new X509TrustManager() {
                    @Override
                    public X509Certificate[] getAcceptedIssuers() {
                        return new X509Certificate[0];
                    }

                    @Override
                    public void checkClientTrusted(X509Certificate[] chain, String authType) {
                    }

                    @Override
                    public void checkServerTrusted(X509Certificate[] chain, String authType) {
                    }
                }
            };
            SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, trustAll, new SecureRandom());
            return sslContext;
        } catch (Exception e) {
            throw new IllegalStateException("Não foi possível configurar SSL local para OpenAI");
        }
    }

    public static class OpenAiApiException extends Exception {
        private final String debugMessage;
        private final int httpStatus;
        private final String sanitizedBody;

        public OpenAiApiException(String debugMessage) {
            this(debugMessage, 0, "");
        }

        public OpenAiApiException(String debugMessage, int httpStatus, String sanitizedBody) {
            super(debugMessage);
            this.debugMessage = debugMessage;
            this.httpStatus = httpStatus;
            this.sanitizedBody = sanitizedBody == null ? "" : sanitizedBody;
        }

        public String getDebugMessage() {
            return debugMessage;
        }

        public int getHttpStatus() {
            return httpStatus;
        }

        public String getSanitizedBody() {
            return sanitizedBody;
        }
    }

    public SugestaoViagem gerarSugestaoViagem(PesquisaRequest request, List<VooInfo> voosIda, List<VooInfo> voosRegresso,
            List<HotelSugestao> hoteisReais)
            throws OpenAiApiException {
        if (!ApiConfig.hasOpenAIKey()) {
            throw new OpenAiApiException("OpenAI key em falta");
        }
        List<VooInfo> ida = voosIda == null ? List.of() : voosIda;
        List<VooInfo> regresso = voosRegresso == null ? List.of() : voosRegresso;
        List<HotelSugestao> hoteis = hoteisReais == null ? List.of() : hoteisReais;
        if (ApiConfig.isIaeduAgentMode()) {
            return gerarSugestaoIaeduAgent(request, ida, regresso, hoteis);
        }
        return gerarSugestaoChatCompletions(request, ida, regresso, hoteis);
    }

    public SugestaoViagem sugestaoQuandoErroExterno(PesquisaRequest request) {
        SugestaoViagem s = new SugestaoViagem();
        String d = "";
        if (request != null && request.destino != null && !request.destino.trim().isEmpty()) {
            d = request.destino.trim();
        }
        s.titulo = d.isBlank() ? "Viagem sugerida" : "Pacote para " + d;
        s.descricao = "Sugestão baseada nos voos encontrados e nas opções de alojamento indicadas.";
        s.hotelSugerido = "";
        s.transporteSugerido = "";
        s.precoEstimadoTotal = 0;
        s.imagemKeywords = "";
        return s;
    }

    public SugestaoViagem gerarSugestaoFinal(CriarSugestaoRequest pedido) throws OpenAiApiException {
        if (!ApiConfig.hasOpenAIKey()) {
            throw new OpenAiApiException("OpenAI key em falta");
        }
        if (pedido == null || !pedido.isValid()) {
            throw new OpenAiApiException("Pedido de sugestão inválido");
        }
        if (ApiConfig.isIaeduAgentMode()) {
            return gerarSugestaoFinalIaedu(pedido);
        }
        return gerarSugestaoFinalChat(pedido);
    }

    public SugestaoViagem sugestaoFinalFallback(CriarSugestaoRequest pedido) {
        SugestaoViagem s = new SugestaoViagem();
        String dest = pedido != null && pedido.destino != null ? pedido.destino.trim() : "";
        s.titulo = dest.isBlank() ? "A sua viagem" : "Pacote para " + dest;
        s.descricao = "Resumo da viagem com base nas escolhas que fez. Os valores são estimativas da agência.";
        s.transporteSugerido = buildFallbackTransport(pedido);
        s.resumoFinal = s.descricao;
        s.hotelSugerido = pedido != null && pedido.hotelSelecionado != null
                ? safeText(pedido.hotelSelecionado.nome) : "";
        double total = 0;
        if (pedido != null && pedido.vooIdaSelecionado != null) {
            total += pedido.vooIdaSelecionado.precoTotal;
        }
        if (pedido != null && pedido.vooRegressoSelecionado != null) {
            total += pedido.vooRegressoSelecionado.precoTotal;
        }
        if (pedido != null && pedido.hotelSelecionado != null) {
            total += pedido.hotelSelecionado.precoEstimado;
        }
        s.precoEstimadoTotal = total;
        s.imagemKeywords = "";
        for (String atividade : buildFallbackAtividades(dest)) {
            s.atividades.add(atividade);
        }
        return s;
    }

    private SugestaoViagem gerarSugestaoFinalIaedu(CriarSugestaoRequest pedido) throws OpenAiApiException {
        String endpoint = ApiConfig.OPENAI_BASE_URL;
        String message = buildFinalPrompt(pedido);
        Map<String, String> fields = new LinkedHashMap<>();
        fields.put("channel_id", ApiConfig.OPENAI_CHANNEL_ID);
        fields.put("thread_id", ApiConfig.OPENAI_THREAD_ID);
        fields.put("user_info", "{}");
        fields.put("message", message);

        String boundary = "----TravelExplorer" + UUID.randomUUID();
        byte[] multipartBody = buildMultipartBody(boundary, fields);

        HttpResponse<String> resp;
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .timeout(Duration.ofSeconds(90))
                    .header(ApiConfig.OPENAI_AUTH_HEADER, ApiConfig.buildOpenAiAuthHeaderValue())
                    .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                    .POST(HttpRequest.BodyPublishers.ofByteArray(multipartBody))
                    .build();
            resp = http.send(req, HttpResponse.BodyHandlers.ofString());
        } catch (Exception e) {
            throw new OpenAiApiException("Erro de ligação IAedu: " + safeMessage(e.getMessage()));
        }

        String responseBody = resp.body() == null ? "" : resp.body();
        if (resp.statusCode() != 200) {
            String sanitized = sanitizeBody(responseBody, DEBUG_BODY_MAX);
            logHttpFailure(endpoint, resp.statusCode(), responseBody);
            throw new OpenAiApiException("OpenAI HTTP " + resp.statusCode(), resp.statusCode(), sanitized);
        }

        PesquisaRequest ctx = toPesquisaRequest(pedido);
        return parseIaeduResponseFinal(responseBody, ctx, pedido);
    }

    private SugestaoViagem gerarSugestaoFinalChat(CriarSugestaoRequest pedido) throws OpenAiApiException {
        String userPrompt = buildFinalPrompt(pedido);
        String body = "{"
            + "\"model\":\"" + escapeJson(ApiConfig.OPENAI_MODEL) + "\","
            + "\"response_format\":{\"type\":\"json_object\"},"
            + "\"messages\":["
            +   "{\"role\":\"system\",\"content\":\"És um assistente de agência de viagens em Portugal. Responde apenas com JSON válido em português de Portugal.\"},"
            +   "{\"role\":\"user\",\"content\":\"" + escapeJson(userPrompt) + "\"}"
            + "],"
            + "\"temperature\":0.4"
            + "}";

        HttpResponse<String> resp;
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(ApiConfig.OPENAI_BASE_URL))
                    .timeout(Duration.ofSeconds(45))
                    .header("Content-Type", "application/json")
                    .header(ApiConfig.OPENAI_AUTH_HEADER, ApiConfig.buildOpenAiAuthHeaderValue())
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();
            resp = http.send(req, HttpResponse.BodyHandlers.ofString());
        } catch (Exception e) {
            throw new OpenAiApiException("Erro de ligação OpenAI: " + safeMessage(e.getMessage()));
        }

        String responseBody = resp.body() == null ? "" : resp.body();
        if (resp.statusCode() != 200) {
            String sanitized = sanitizeBody(responseBody, DEBUG_BODY_MAX);
            logHttpFailure(resp.statusCode(), responseBody);
            throw new OpenAiApiException("OpenAI HTTP " + resp.statusCode(), resp.statusCode(), sanitized);
        }

        try {
            String content = extractAssistantContent(responseBody);
            SugestaoViagem sugestao = SugestaoViagem.fromJson(content);
            if (isEmpty(sugestao.titulo) && isEmpty(sugestao.descricao)) {
                throw new OpenAiApiException("Sugestão inválida na resposta", 200, sanitizeBody(responseBody, DEBUG_BODY_MAX));
            }
            enrichFinalFromPedido(sugestao, pedido);
            return sugestao;
        } catch (OpenAiApiException e) {
            throw e;
        } catch (Exception e) {
            throw new OpenAiApiException("Resposta OpenAI inválida: " + safeMessage(e.getMessage()), 200, sanitizeBody(responseBody, DEBUG_BODY_MAX));
        }
    }

    private SugestaoViagem parseIaeduResponseFinal(String responseBody, PesquisaRequest ctx, CriarSugestaoRequest pedido) {
        lastIaeduDebug.rawLength = responseBody == null ? 0 : responseBody.length();
        String assistantText = extractIaeduAssistantText(responseBody);
        lastIaeduDebug.textPreview = truncateText(assistantText, DEBUG_TEXT_PREVIEW_MAX);

        String cleaned = removeJsonFences(assistantText.trim());
        String json = extractJsonObjectWithTitulo(cleaned);
        if (json.isBlank()) {
            json = extractJsonObjectWithTitulo(assistantText);
        }
        if (!json.isBlank()) {
            SugestaoViagem parsed = SugestaoViagem.fromJson(json);
            if (isStructuredFinalSugestao(parsed)) {
                enrichFinalFromPedido(parsed, pedido);
                return parsed;
            }
        }
        if (cleaned.startsWith("{")) {
            SugestaoViagem parsed = SugestaoViagem.fromJson(cleaned);
            if (isStructuredFinalSugestao(parsed)) {
                enrichFinalFromPedido(parsed, pedido);
                return parsed;
            }
        }
        return sugestaoFinalFallback(pedido);
    }

    private boolean isStructuredFinalSugestao(SugestaoViagem s) {
        if (s == null || isEmpty(s.titulo)) {
            return false;
        }
        return !isEmpty(s.descricao)
                || !isEmpty(s.transporteSugerido)
                || (s.atividades != null && !s.atividades.isEmpty())
                || s.precoEstimadoTotal > 0
                || !isEmpty(s.resumoFinal);
    }

    private void enrichFinalFromPedido(SugestaoViagem s, CriarSugestaoRequest pedido) {
        if (s == null || pedido == null) {
            return;
        }
        if (isEmpty(s.resumoFinal) && !isEmpty(s.descricao)) {
            s.resumoFinal = s.descricao;
        }
        if (isEmpty(s.descricao) && !isEmpty(s.resumoFinal)) {
            s.descricao = s.resumoFinal;
        }
        if (pedido.hotelSelecionado != null && !safeText(pedido.hotelSelecionado.nome).isEmpty()) {
            s.hotelSugerido = safeText(pedido.hotelSelecionado.nome);
        }
        s.hoteisOpcoes = new java.util.ArrayList<>();
        s.imagemKeywords = "";
    }

    private PesquisaRequest toPesquisaRequest(CriarSugestaoRequest pedido) {
        PesquisaRequest r = new PesquisaRequest();
        if (pedido == null) {
            return r;
        }
        r.origem = pedido.origem;
        r.destino = pedido.destino;
        r.dataPartida = pedido.dataPartida;
        r.dataRegresso = pedido.dataRegresso;
        r.adultos = pedido.adultos;
        r.criancas = pedido.criancas;
        return r;
    }

    private String buildFinalPrompt(CriarSugestaoRequest pedido) {
        StringBuilder sb = new StringBuilder();
        sb.append("Cria um pacote de viagem premium com base APENAS nas escolhas já confirmadas pelo cliente.\n\n");
        appendSelectedTripContext(sb, pedido);
        sb.append("\nRegras obrigatórias:\n");
        sb.append("- Responde apenas com JSON válido, sem markdown e sem texto extra.\n");
        sb.append("- Não inventes voos nem hotéis adicionais.\n");
        sb.append("- Não peças imagens nem palavras-chave de imagem.\n");
        sb.append("- Usa português de Portugal, textos curtos e elegantes.\n");
        sb.append("- O precoEstimadoTotal deve ser coerente com os preços já escolhidos (voos + hotel se existir).\n");
        sb.append("- Usa exatamente estas chaves: titulo, descricao, transporte, transporteSugerido, atividades, precoEstimadoTotal, resumoFinal.\n");
        sb.append("- transporte deve ser um objeto JSON com: tipo (Metro, Táxi, Uber/Bolt, Autocarro, Comboio, Transfer privado ou Shuttle), origem, destino, duracao, descricao, precoEstimado.\n");
        sb.append("- O titulo deve ser apelativo e específico ao destino (ex.: \"Escapadinha romântica em Lisboa\").\n");
        sb.append("- A descricao deve ser curta mas atrativa (2-3 frases).\n");
        sb.append("- Inclui entre 5 e 7 atividades CONCRETAS e específicas do destino (monumentos, bairros, experiências reais). Evita frases genéricas.\n");
        sb.append("- PROIBIDO usar atividades vagas como \"Explorar o centro histórico\", \"Tempo livre para descanso\" ou \"Visitar pontos turísticos\".\n");
        sb.append("- transporteSugerido deve ser realista: indica tipo (Metro, Táxi, Uber/Bolt, Autocarro, Shuttle, Comboio, Transfer privado), rota de-para, duração aproximada e alternativa breve.\n");
        sb.append("- PROIBIDO usar frases genéricas de transporte como \"Transfers e deslocações locais conforme o destino\".\n");
        sb.append("- Exemplo de transporteSugerido: \"Metro do Aeroporto Humberto Delgado até ao centro de Lisboa, cerca de 25 minutos. Alternativa: táxi/Uber até ao hotel, cerca de 20 minutos.\"\n");
        appendExpectedFinalJsonShape(sb);
        sb.append("O resumoFinal deve ser um parágrafo curto de agência de viagens.\n");
        return sb.toString();
    }

    private void appendSelectedTripContext(StringBuilder sb, CriarSugestaoRequest pedido) {
        if (pedido == null) {
            return;
        }
        sb.append("Rota: ").append(safeText(pedido.origem)).append(" → ").append(safeText(pedido.destino)).append('\n');
        sb.append("Datas: ").append(safeText(pedido.dataPartida)).append(" a ").append(safeText(pedido.dataRegresso)).append('\n');
        sb.append("Passageiros: ").append(pedido.adultos).append(" adulto(s), ").append(pedido.criancas).append(" criança(s)\n\n");
        if (pedido.vooIdaSelecionado != null) {
            sb.append("Voo de ida escolhido:\n");
            appendCompactVoo(sb, pedido.vooIdaSelecionado);
        }
        if (pedido.vooRegressoSelecionado != null) {
            sb.append("Voo de regresso escolhido:\n");
            appendCompactVoo(sb, pedido.vooRegressoSelecionado);
        }
        if (pedido.hotelSelecionado != null && !safeText(pedido.hotelSelecionado.nome).isEmpty()) {
            sb.append("Alojamento escolhido:\n");
            appendCompactHotel(sb, pedido.hotelSelecionado);
        } else {
            sb.append("Alojamento: o cliente optou por continuar sem alojamento selecionado.\n");
        }
    }

    private void appendCompactVoo(StringBuilder sb, VooInfo v) {
        sb.append("- ").append(safeText(v.companhia)).append(" ").append(safeText(v.numeroVoo))
          .append(", ").append(safeText(v.origem)).append(" ").append(formatClock(v.partida))
          .append(" → ").append(safeText(v.destino)).append(" ").append(formatClock(v.chegada))
          .append(", ").append(formatEuroCompact(v.precoTotal)).append('\n');
    }

    private void appendCompactHotel(StringBuilder sb, HotelSugestao h) {
        sb.append("- ").append(safeText(h.nome)).append(" | ").append(safeText(h.categoria))
          .append(" | ").append(safeText(h.zona)).append(" | preço ").append(formatEuroCompact(h.precoEstimado));
        if (h.rating > 0) {
            if (h.rating <= 5 && Math.abs(h.rating - Math.round(h.rating)) < 0.01) {
                sb.append(" | ").append(Math.round(h.rating)).append(" estrelas");
            } else {
                sb.append(" | ").append(String.format(java.util.Locale.forLanguageTag("pt-PT"), "%.1f avaliação", h.rating));
            }
        }
        if (h.reviews > 0) {
            sb.append(" | ").append(h.reviews).append(" avaliações");
        }
        sb.append('\n');
    }

    private String buildFallbackTransport(CriarSugestaoRequest pedido) {
        String dest = pedido != null && pedido.destino != null ? pedido.destino.trim() : "";
        String aeroporto = dest.isEmpty() ? "aeroporto de chegada" : "aeroporto de " + dest;
        String alvo = dest.isEmpty() ? "o alojamento" : dest;
        if (pedido != null && pedido.hotelSelecionado != null && !safeText(pedido.hotelSelecionado.zona).isEmpty()) {
            alvo = pedido.hotelSelecionado.zona;
        } else if (pedido != null && pedido.hotelSelecionado != null && !safeText(pedido.hotelSelecionado.nome).isEmpty()) {
            alvo = pedido.hotelSelecionado.nome;
        }
        return "Transfer do " + aeroporto + " até " + alvo + ", cerca de 25 minutos. Alternativa: táxi ou Uber/Bolt, cerca de 20 minutos.";
    }

    private java.util.List<String> buildFallbackAtividades(String destino) {
        java.util.List<String> list = new java.util.ArrayList<>();
        String d = destino != null ? destino.trim().toLowerCase() : "";
        if (d.contains("lisboa")) {
            list.add("Visita ao Mosteiro dos Jerónimos e Torre de Belém");
            list.add("Passeio pelo Chiado e Bairro Alto");
            list.add("Miradouro da Senhora do Monte ao final da tarde");
            list.add("Passeio de elétrico 28 pelo centro histórico");
            list.add("Jantar típico com fado em Alfama");
            list.add("Café e pastel de nata na Fábrica de Pastéis de Belém");
        } else if (d.contains("porto")) {
            list.add("Cruzeiro no Douro com vista para as margens do Porto");
            list.add("Visita à Livraria Lello e à estação de São Bento");
            list.add("Degustação de vinho na Ribeira");
            list.add("Passeio pela Ponte Dom Luís e Foz do Douro");
            list.add("Francesinha num restaurante tradicional");
        } else if (!d.isEmpty()) {
            list.add("Visita guiada ao centro histórico de " + destino);
            list.add("Passeio gastronómico com especialidades locais");
            list.add("Miradouro ou ponto panorâmico emblemático");
            list.add("Museu ou monumento principal da cidade");
            list.add("Tarde livre para compras e cafés locais");
        } else {
            list.add("Visita ao centro histórico da cidade");
            list.add("Experiência gastronómica local");
            list.add("Passeio panorâmico ao final do dia");
        }
        return list;
    }

    private void appendExpectedFinalJsonShape(StringBuilder sb) {
        sb.append("{\n");
        sb.append("  \"titulo\": \"...\",\n");
        sb.append("  \"descricao\": \"...\",\n");
        sb.append("  \"transporte\": {\"tipo\":\"Metro\",\"origem\":\"...\",\"destino\":\"...\",\"duracao\":\"25 minutos\",\"descricao\":\"...\",\"precoEstimado\":4.0},\n");
        sb.append("  \"transporteSugerido\": \"...\",\n");
        sb.append("  \"atividades\": [\"...\", \"...\", \"...\", \"...\", \"...\"],\n");
        sb.append("  \"precoEstimadoTotal\": 0.0,\n");
        sb.append("  \"resumoFinal\": \"...\"\n");
        sb.append("}\n");
    }

    private SugestaoViagem gerarSugestaoIaeduAgent(PesquisaRequest request, List<VooInfo> voosIda, List<VooInfo> voosRegresso,
            List<HotelSugestao> hoteisReais)
            throws OpenAiApiException {
        String endpoint = ApiConfig.OPENAI_BASE_URL;
        String message = buildIaeduPrompt(request, voosIda, voosRegresso, hoteisReais);
        Map<String, String> fields = new LinkedHashMap<>();
        fields.put("channel_id", ApiConfig.OPENAI_CHANNEL_ID);
        fields.put("thread_id", ApiConfig.OPENAI_THREAD_ID);
        fields.put("user_info", "{}");
        fields.put("message", message);

        String boundary = "----TravelExplorer" + UUID.randomUUID();
        byte[] multipartBody = buildMultipartBody(boundary, fields);

        HttpResponse<String> resp;
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .timeout(Duration.ofSeconds(90))
                    .header(ApiConfig.OPENAI_AUTH_HEADER, ApiConfig.buildOpenAiAuthHeaderValue())
                    .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                    .POST(HttpRequest.BodyPublishers.ofByteArray(multipartBody))
                    .build();
            resp = http.send(req, HttpResponse.BodyHandlers.ofString());
        } catch (Exception e) {
            e.printStackTrace();
            throw new OpenAiApiException("Erro de ligação IAedu: " + safeMessage(e.getMessage()));
        }

        String responseBody = resp.body() == null ? "" : resp.body();
        if (resp.statusCode() != 200) {
            String sanitized = sanitizeBody(responseBody, DEBUG_BODY_MAX);
            logHttpFailure(endpoint, resp.statusCode(), responseBody);
            throw new OpenAiApiException("OpenAI HTTP " + resp.statusCode(), resp.statusCode(), sanitized);
        }

        return parseIaeduResponse(responseBody, request);
    }

    private SugestaoViagem parseIaeduResponse(String responseBody, PesquisaRequest request) {
        lastIaeduDebug.rawLength = responseBody == null ? 0 : responseBody.length();
        String assistantText = extractIaeduAssistantText(responseBody);
        lastIaeduDebug.textPreview = truncateText(assistantText, DEBUG_TEXT_PREVIEW_MAX);

        String cleaned = removeJsonFences(assistantText.trim());
        String json = extractJsonObjectWithTitulo(cleaned);
        if (json.isBlank()) {
            json = extractJsonObjectWithTitulo(assistantText);
        }
        if (!json.isBlank()) {
            SugestaoViagem parsed = SugestaoViagem.fromJson(json);
            if (isStructuredSugestao(parsed)) {
                return parsed;
            }
        }
        if (cleaned.startsWith("{")) {
            SugestaoViagem parsed = SugestaoViagem.fromJson(cleaned);
            if (isStructuredSugestao(parsed)) {
                return parsed;
            }
        }
        return fallbackSugestao(request, assistantText);
    }

    private String extractIaeduAssistantText(String responseBody) {
        if (responseBody == null || responseBody.isBlank()) {
            return "";
        }
        StringBuilder reconstructed = new StringBuilder();
        int pos = 0;
        while (pos < responseBody.length()) {
            int keyIdx = findNextContentKey(responseBody, pos);
            if (keyIdx < 0) {
                break;
            }
            int colon = responseBody.indexOf(':', keyIdx);
            if (colon < 0) {
                break;
            }
            int valueStart = colon + 1;
            while (valueStart < responseBody.length()
                    && Character.isWhitespace(responseBody.charAt(valueStart))) {
                valueStart++;
            }
            if (valueStart >= responseBody.length()) {
                break;
            }
            if (responseBody.charAt(valueStart) == 'n'
                    && responseBody.regionMatches(valueStart, "null", 0, 4)) {
                pos = valueStart + 4;
                continue;
            }
            if (responseBody.charAt(valueStart) != '"') {
                pos = keyIdx + 9;
                continue;
            }
            reconstructed.append(readQuotedJsonString(responseBody, valueStart));
            pos = indexAfterQuotedString(responseBody, valueStart);
        }
        if (reconstructed.length() > 0) {
            return reconstructed.toString();
        }
        return extractJsonContentField(responseBody);
    }

    private int findNextContentKey(String text, int from) {
        int a = text.indexOf("\"content\":\"", from);
        int b = text.indexOf("\"content\": \"", from);
        if (a < 0) {
            return b;
        }
        if (b < 0) {
            return a;
        }
        return Math.min(a, b);
    }

    private String readQuotedJsonString(String text, int quoteStart) {
        if (quoteStart < 0 || quoteStart >= text.length() || text.charAt(quoteStart) != '"') {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (int i = quoteStart + 1; i < text.length(); i++) {
            char c = text.charAt(i);
            if (c == '\\' && i + 1 < text.length()) {
                char next = text.charAt(++i);
                switch (next) {
                    case 'n': sb.append('\n'); break;
                    case 'r': sb.append('\r'); break;
                    case 't': sb.append('\t'); break;
                    case '"': sb.append('"'); break;
                    case '\\': sb.append('\\'); break;
                    default: sb.append(next);
                }
            } else if (c == '"') {
                break;
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    private int indexAfterQuotedString(String text, int quoteStart) {
        if (quoteStart < 0 || quoteStart >= text.length() || text.charAt(quoteStart) != '"') {
            return text.length();
        }
        for (int i = quoteStart + 1; i < text.length(); i++) {
            char c = text.charAt(i);
            if (c == '\\' && i + 1 < text.length()) {
                i++;
                continue;
            }
            if (c == '"') {
                return i + 1;
            }
        }
        return text.length();
    }

    private String removeJsonFences(String text) {
        if (text == null || text.isBlank()) {
            return "";
        }
        String trimmed = text.trim();
        if (!trimmed.startsWith("```")) {
            return trimmed;
        }
        int firstLine = trimmed.indexOf('\n');
        if (firstLine > 0) {
            trimmed = trimmed.substring(firstLine + 1);
        }
        int fence = trimmed.lastIndexOf("```");
        if (fence > 0) {
            trimmed = trimmed.substring(0, fence);
        }
        return trimmed.trim();
    }

    private boolean isStructuredSugestao(SugestaoViagem s) {
        if (s == null || isEmpty(s.titulo)) {
            return false;
        }
        return !isEmpty(s.hotelSugerido)
                || !isEmpty(s.transporteSugerido)
                || (s.atividades != null && !s.atividades.isEmpty())
                || (s.hoteisOpcoes != null && !s.hoteisOpcoes.isEmpty())
                || s.precoEstimadoTotal > 0;
    }

    private SugestaoViagem fallbackSugestao(PesquisaRequest request, String assistantText) {
        SugestaoViagem s = new SugestaoViagem();
        String destino = request == null || isEmpty(request.destino) ? "destino" : request.destino.trim();
        s.titulo = "Sugestão de viagem para " + destino;
        if (isReadableAssistantText(assistantText)) {
            s.descricao = truncateText(assistantText.trim(), FALLBACK_DESC_MAX);
        } else {
            s.descricao = "Não foi possível estruturar a sugestão automaticamente.";
        }
        s.hotelSugerido = "";
        s.transporteSugerido = "";
        s.imagemKeywords = "";
        s.precoEstimadoTotal = 0;
        return s;
    }

    private boolean isReadableAssistantText(String text) {
        if (text == null || text.isBlank()) {
            return false;
        }
        String trimmed = text.trim();
        if (trimmed.contains("\"run_id\"") || trimmed.contains("\"type\"")) {
            return false;
        }
        if (trimmed.startsWith("{") && trimmed.contains("\"content\"")) {
            return false;
        }
        return trimmed.length() <= FALLBACK_DESC_MAX;
    }

    private byte[] buildMultipartBody(String boundary, Map<String, String> fields) {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> entry : fields.entrySet()) {
            sb.append("--").append(boundary).append("\r\n");
            sb.append("Content-Disposition: form-data; name=\"")
              .append(entry.getKey())
              .append("\"\r\n\r\n");
            sb.append(entry.getValue() == null ? "" : entry.getValue()).append("\r\n");
        }
        sb.append("--").append(boundary).append("--\r\n");
        return sb.toString().getBytes(StandardCharsets.UTF_8);
    }

    private SugestaoViagem gerarSugestaoChatCompletions(PesquisaRequest request, List<VooInfo> voosIda, List<VooInfo> voosRegresso,
            List<HotelSugestao> hoteisReais)
            throws OpenAiApiException {
        String userPrompt = buildPrompt(request, voosIda, voosRegresso, hoteisReais);
        String body = "{"
            + "\"model\":\"" + escapeJson(ApiConfig.OPENAI_MODEL) + "\","
            + "\"response_format\":{\"type\":\"json_object\"},"
            + "\"messages\":["
            +   "{\"role\":\"system\",\"content\":\"És um assistente de agência de viagens em Portugal. Responde apenas com JSON válido em português de Portugal.\"},"
            +   "{\"role\":\"user\",\"content\":\"" + escapeJson(userPrompt) + "\"}"
            + "],"
            + "\"temperature\":0.4"
            + "}";

        HttpResponse<String> resp;
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(ApiConfig.OPENAI_BASE_URL))
                    .timeout(Duration.ofSeconds(45))
                    .header("Content-Type", "application/json")
                    .header(ApiConfig.OPENAI_AUTH_HEADER, ApiConfig.buildOpenAiAuthHeaderValue())
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();
            resp = http.send(req, HttpResponse.BodyHandlers.ofString());
        } catch (Exception e) {
            e.printStackTrace();
            throw new OpenAiApiException("Erro de ligação OpenAI: " + safeMessage(e.getMessage()));
        }

        String responseBody = resp.body() == null ? "" : resp.body();
        if (resp.statusCode() != 200) {
            String sanitized = sanitizeBody(responseBody, DEBUG_BODY_MAX);
            logHttpFailure(resp.statusCode(), responseBody);
            throw new OpenAiApiException("OpenAI HTTP " + resp.statusCode(), resp.statusCode(), sanitized);
        }

        try {
            String content = extractAssistantContent(responseBody);
            SugestaoViagem sugestao = SugestaoViagem.fromJson(content);
            if (isEmpty(sugestao.titulo) && isEmpty(sugestao.descricao)) {
                String sanitized = sanitizeBody(responseBody, DEBUG_BODY_MAX);
                logHttpFailure(200, responseBody);
                throw new OpenAiApiException("Sugestão inválida na resposta", 200, sanitized);
            }
            return sugestao;
        } catch (OpenAiApiException e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            String sanitized = sanitizeBody(responseBody, DEBUG_BODY_MAX);
            logHttpFailure(200, responseBody);
            throw new OpenAiApiException("Resposta OpenAI inválida: " + safeMessage(e.getMessage()), 200, sanitized);
        }
    }

    public String pesquisarContexto(String origem, String destino,
                                    int adultos, int criancas,
                                    String dataPartida, String dataRegresso) throws Exception {
        PesquisaRequest request = new PesquisaRequest();
        request.origem = origem;
        request.destino = destino;
        request.adultos = adultos;
        request.criancas = criancas;
        request.dataPartida = dataPartida;
        request.dataRegresso = dataRegresso;
        SugestaoViagem sugestao = gerarSugestaoViagem(request, List.of(), List.of(), List.of());
        return "{"
            + "\"origemIATA\":\"\","
            + "\"destinoIATA\":\"\","
            + "\"alojamento\":{\"nome\":\"" + escapeJson(sugestao.hotelSugerido) + "\",\"tipo\":\"hotel\",\"precoPorNoite\":0,\"precoTotal\":"
            + sugestao.precoEstimadoTotal + ",\"moeda\":\"EUR\",\"moradaAprox\":\"\"},"
            + "\"transfer\":{\"tipo\":\"" + escapeJson(sugestao.transporteSugerido) + "\",\"duracaoMin\":0,\"precoEstimado\":0,\"moeda\":\"EUR\",\"descricao\":\"\"}"
            + "}";
    }

    private void logHttpFailure(String endpoint, int statusCode, String body) {
        System.err.println("[OpenAIClient] endpoint=" + endpoint + " status=" + statusCode);
        System.err.println("[OpenAIClient] body=" + sanitizeBody(body, LOG_BODY_MAX));
    }

    private void logHttpFailure(int statusCode, String body) {
        logHttpFailure(ApiConfig.OPENAI_BASE_URL, statusCode, body);
    }

    private String buildIaeduPrompt(PesquisaRequest request, List<VooInfo> voosIda, List<VooInfo> voosRegresso,
            List<HotelSugestao> hoteisReais) {
        StringBuilder sb = new StringBuilder();
        appendTravelContext(sb, request, voosIda, voosRegresso);
        appendCompactHotels(sb, hoteisReais);
        sb.append("\nRegras obrigatórias:\n");
        sb.append("- Produz UMA sugestão premium de viagem com linguagem de agência de viagens.\n");
        sb.append("- Responde apenas com JSON válido, sem markdown, sem ```json e sem texto antes ou depois.\n");
        sb.append("- Não escrevas \"Processing\", estados intermédios nem explicações fora do JSON.\n");
        sb.append("- Usa português de Portugal com acentuação correta e textos curtos e polidos.\n");
        sb.append("- Não reveles chaves nem dados internos de API nas respostas.\n");
        boolean temReais = hoteisReais != null && !hoteisReais.isEmpty();
        if (temReais) {
            sb.append("- Usa os hotéis reais listados como base. Não inventes outros nomes de hotéis.\n");
            sb.append("- O campo hotelSugerido deve ser o primeiro hotel real indicado pela lista quando fizer sentido.\n");
            sb.append("- Inclui hoteisOpcoes como array vazio []. Os hotéis mostrados vêm dos dados reais já obtidos pela aplicação.\n");
            sb.append("- Usa exatamente estas chaves: titulo, descricao, hotelSugerido, transporteSugerido, atividades, precoEstimadoTotal, hoteisOpcoes.\n");
            appendHotelGuidanceReais(sb);
            appendExpectedJsonShapeEmptyHotels(sb);
            sb.append("Inclui entre 3 e 5 atividades. O precoEstimadoTotal deve ser coerente com voos e preços de hotel reais mencionados no contexto.\n");
        } else {
            sb.append("- Não inventes disponibilidade real de hotéis; usa opção sugerida e preço estimado.\n");
            sb.append("- Usa exatamente estas chaves: titulo, descricao, hotelSugerido, transporteSugerido, atividades, precoEstimadoTotal, hoteisOpcoes.\n");
            appendHotelGuidance(sb);
            appendExpectedJsonShape(sb);
            sb.append("Inclui exatamente 3 opções em hoteisOpcoes e entre 3 e 5 atividades. O precoEstimadoTotal deve ser coerente com os voos e alojamento sugeridos.\n");
        }
        return sb.toString();
    }

    private String buildPrompt(PesquisaRequest request, List<VooInfo> voosIda, List<VooInfo> voosRegresso,
            List<HotelSugestao> hoteisReais) {
        StringBuilder sb = new StringBuilder();
        appendTravelContext(sb, request, voosIda, voosRegresso);
        appendCompactHotels(sb, hoteisReais);
        sb.append("\nDevolve APENAS um JSON válido com esta estrutura exata:\n");
        boolean temReais = hoteisReais != null && !hoteisReais.isEmpty();
        if (temReais) {
            sb.append("- Os hotéis reais aparecem no contexto compacto acima (SerpApi). Não inventes nomes de hotéis além desses quando descreves o pacote.\n");
            appendHotelGuidanceReais(sb);
            appendExpectedJsonShapeEmptyHotels(sb);
            sb.append("hotelSugerido deve corresponder ao primeiro ou melhor dos hotéis reais quando adequado.\n");
            sb.append("hoteisOpcoes deve ser []\n");
            sb.append("Inclui entre 3 e 5 atividades. Usa português de Portugal.\n");
        } else {
            appendHotelGuidance(sb);
            appendExpectedJsonShape(sb);
            sb.append("Inclui exatamente 3 opções em hoteisOpcoes e entre 3 e 5 atividades práticas. Usa português de Portugal.\n");
        }
        return sb.toString();
    }

    private void appendHotelGuidance(StringBuilder sb) {
        sb.append("\nContexto de negócio:\n");
        sb.append("- A TravelExplorer é uma agência de viagens, não um site de reserva direta de hotéis.\n");
        sb.append("- Em hoteisOpcoes, recomenda estilos de alojamento, zonas e tipos de hotel plausíveis para a viagem.\n");
        sb.append("- Não inventes inventário real nem preços finais de reserva.\n");
        sb.append("- Usa linguagem como: opção sugerida, zona recomendada, categoria estimada, preço estimado.\n");
        sb.append("- Cada hotel deve explicar brevemente porque encaixa no destino e no perfil da viagem.\n");
    }

    private void appendHotelGuidanceReais(StringBuilder sb) {
        sb.append("\nContexto de negócio:\n");
        sb.append("- Os hotéis listados foram obtidos através de dados públicos consolidados por motor de pesquisa; não garantes disponibilidade final.\n");
        sb.append("- Descreve apenas o pacote e atividades usando os nomes já fornecidos.\n");
    }

    private void appendCompactHotels(StringBuilder sb, List<HotelSugestao> hoteis) {
        sb.append("\nHotéis reais (compacto, até 5 entradas):\n");
        if (hoteis == null || hoteis.isEmpty()) {
            sb.append("- Sem resultados na pesquisa de hotéis.\n");
            return;
        }
        int lim = Math.min(hoteis.size(), 5);
        for (int i = 0; i < lim; i++) {
            HotelSugestao h = hoteis.get(i);
            if (h == null || safeText(h.nome).isEmpty()) {
                continue;
            }
            sb.append("- ").append(safeText(h.nome))
              .append(" | ").append(safeText(h.categoria)).append(" | preço ").append(formatEuroCompact(h.precoEstimado));
            if (h.rating > 0) {
                sb.append(" | classificações ").append(h.rating);
            }
            if (h.reviews > 0) {
                sb.append(" | avaliações ").append(h.reviews);
            }
            if (!safeText(h.amenities).isEmpty()) {
                sb.append(" | ").append(truncateHotelLine(h.amenities, 80));
            }
            sb.append('\n');
        }
    }

    private String truncateHotelLine(String s, int max) {
        String t = s == null ? "" : s.trim();
        if (t.length() <= max) {
            return t;
        }
        return t.substring(0, max).trim() + "…";
    }

    private void appendExpectedJsonShapeEmptyHotels(StringBuilder sb) {
        sb.append("{\n");
        sb.append("  \"titulo\": \"...\",\n");
        sb.append("  \"descricao\": \"...\",\n");
        sb.append("  \"hotelSugerido\": \"...\",\n");
        sb.append("  \"transporteSugerido\": \"...\",\n");
        sb.append("  \"atividades\": [\"...\", \"...\", \"...\"],\n");
        sb.append("  \"precoEstimadoTotal\": 0.0,\n");
        sb.append("  \"hoteisOpcoes\": []\n");
        sb.append("}\n");
    }

    private void appendTravelContext(StringBuilder sb, PesquisaRequest request,
                                    List<VooInfo> voosIda, List<VooInfo> voosRegresso) {
        sb.append("Cria uma sugestão premium de pacote de viagem para ");
        sb.append(request.adultos).append(" adulto(s) e ").append(request.criancas).append(" criança(s), ");
        sb.append("de ").append(request.origem).append(" para ").append(request.destino).append(", ");
        sb.append("com partida em ").append(request.dataPartida).append(" e regresso em ")
          .append(request.dataRegresso).append(".\n\n");
        sb.append("Resumo compacto dos voos encontrados (não inventes voos adicionais):\n");
        appendCompactFlightLeg(sb, "Ida", voosIda);
        appendCompactFlightLeg(sb, "Regresso", voosRegresso);
    }

    private void appendCompactFlightLeg(StringBuilder sb, String label, List<VooInfo> voos) {
        sb.append(label).append(":\n");
        if (voos == null || voos.isEmpty()) {
            sb.append("- Sem opções disponíveis nesta pesquisa.\n");
            return;
        }
        double minPrice = Double.MAX_VALUE;
        double maxPrice = 0;
        VooInfo cheapest = null;
        for (VooInfo voo : voos) {
            if (voo == null) {
                continue;
            }
            if (voo.precoTotal < minPrice) {
                minPrice = voo.precoTotal;
                cheapest = voo;
            }
            if (voo.precoTotal > maxPrice) {
                maxPrice = voo.precoTotal;
            }
        }
        sb.append("- ").append(voos.size()).append(" opções\n");
        if (minPrice < Double.MAX_VALUE) {
            sb.append("- preço mínimo ").append(formatEuroCompact(minPrice)).append("\n");
        }
        if (maxPrice > 0 && maxPrice > minPrice) {
            sb.append("- preço máximo ").append(formatEuroCompact(maxPrice)).append("\n");
        }
        if (cheapest != null) {
            sb.append("- mais barato: ").append(formatCheapestFlight(cheapest)).append("\n");
        }
    }

    private String formatCheapestFlight(VooInfo voo) {
        String airline = safeText(voo.companhia);
        String flightNo = safeText(voo.numeroVoo);
        String label = (airline + " " + flightNo).trim();
        if (label.isBlank()) {
            label = "Voo";
        }
        return label
            + ", " + safeText(voo.origem) + " " + formatClock(voo.partida)
            + " → " + safeText(voo.destino) + " " + formatClock(voo.chegada)
            + ", " + formatEuroCompact(voo.precoTotal);
    }

    private String formatClock(String dateTime) {
        if (dateTime == null || dateTime.isBlank()) {
            return "";
        }
        int space = dateTime.indexOf(' ');
        if (space > 0 && dateTime.length() > space + 4) {
            return dateTime.substring(space + 1, Math.min(space + 6, dateTime.length()));
        }
        if (dateTime.length() >= 5 && dateTime.charAt(2) == ':') {
            return dateTime.substring(0, 5);
        }
        return dateTime;
    }

    private String formatEuroCompact(double value) {
        if (value <= 0) {
            return "—";
        }
        if (value == (long) value) {
            return ((long) value) + " €";
        }
        return String.format(java.util.Locale.US, "%.2f €", value);
    }

    private String safeText(String value) {
        return value == null ? "" : value.trim();
    }

    private void appendExpectedJsonShape(StringBuilder sb) {
        sb.append("{\n");
        sb.append("  \"titulo\": \"...\",\n");
        sb.append("  \"descricao\": \"...\",\n");
        sb.append("  \"hotelSugerido\": \"...\",\n");
        sb.append("  \"transporteSugerido\": \"...\",\n");
        sb.append("  \"atividades\": [\"...\", \"...\", \"...\"],\n");
        sb.append("  \"precoEstimadoTotal\": 0.0,\n");
        sb.append("  \"hoteisOpcoes\": [\n");
        sb.append("    {\"nome\":\"...\",\"zona\":\"...\",\"categoria\":\"4 estrelas\",\"descricao\":\"...\",\"precoEstimado\":0.0},\n");
        sb.append("    {\"nome\":\"...\",\"zona\":\"...\",\"categoria\":\"4 estrelas\",\"descricao\":\"...\",\"precoEstimado\":0.0},\n");
        sb.append("    {\"nome\":\"...\",\"zona\":\"...\",\"categoria\":\"4 estrelas\",\"descricao\":\"...\",\"precoEstimado\":0.0}\n");
        sb.append("  ]\n");
        sb.append("}\n");
    }

    private String extractJsonObjectWithTitulo(String text) {
        if (text == null || text.isBlank()) {
            return "";
        }
        int searchFrom = 0;
        while (searchFrom < text.length()) {
            int tituloIdx = text.indexOf("\"titulo\"", searchFrom);
            if (tituloIdx < 0) {
                return "";
            }
            int start = text.lastIndexOf('{', tituloIdx);
            if (start < 0) {
                searchFrom = tituloIdx + 8;
                continue;
            }
            int end = findObjectEnd(text, start);
            if (end > start) {
                return text.substring(start, end + 1);
            }
            searchFrom = tituloIdx + 8;
        }
        return "";
    }

    private int findObjectEnd(String text, int start) {
        int depth = 0;
        boolean inString = false;
        boolean escape = false;
        for (int i = start; i < text.length(); i++) {
            char c = text.charAt(i);
            if (inString) {
                if (escape) {
                    escape = false;
                } else if (c == '\\') {
                    escape = true;
                } else if (c == '"') {
                    inString = false;
                }
                continue;
            }
            if (c == '"') {
                inString = true;
                continue;
            }
            if (c == '{') {
                depth++;
            } else if (c == '}') {
                depth--;
                if (depth == 0) {
                    return i;
                }
            }
        }
        return -1;
    }

    private String extractAssistantContent(String responseBody) throws OpenAiApiException {
        if (responseBody == null || responseBody.isBlank()) {
            throw new OpenAiApiException("Resposta vazia");
        }
        String fromContent = extractJsonContentField(responseBody);
        if (!fromContent.isBlank()) return fromContent;
        String json = extractJsonObjectWithTitulo(responseBody);
        if (!json.isBlank()) return json;
        int jsonStart = responseBody.indexOf('{');
        if (jsonStart >= 0) {
            int jsonEnd = responseBody.lastIndexOf('}');
            if (jsonEnd > jsonStart) return responseBody.substring(jsonStart, jsonEnd + 1);
        }
        throw new OpenAiApiException("Conteúdo JSON não encontrado na resposta");
    }

    private String extractJsonContentField(String responseJson) {
        int contentIdx = findNextContentKey(responseJson, 0);
        if (contentIdx < 0) {
            return "";
        }
        int colon = responseJson.indexOf(':', contentIdx);
        if (colon < 0) {
            return "";
        }
        int valueStart = colon + 1;
        while (valueStart < responseJson.length()
                && Character.isWhitespace(responseJson.charAt(valueStart))) {
            valueStart++;
        }
        if (valueStart >= responseJson.length() || responseJson.charAt(valueStart) != '"') {
            return "";
        }
        return readQuotedJsonString(responseJson, valueStart);
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private String truncateText(String text, int maxLen) {
        if (text == null) return "";
        if (text.length() <= maxLen) return text;
        return text.substring(0, maxLen);
    }

    private String sanitizeBody(String body, int maxLen) {
        if (body == null || body.isEmpty()) return "";
        String cleaned = body
                .replaceAll("(?i)Bearer\\s+[A-Za-z0-9._-]+", "Bearer ***")
                .replaceAll("(?i)sk-[A-Za-z0-9._-]+", "sk-***")
                .replaceAll("(?i)\"api_key\"\\s*:\\s*\"[^\"]+\"", "\"api_key\":\"***\"")
                .replaceAll("(?i)api_key=[^&\\s\"]+", "api_key=***")
                .replaceAll("(?i)x-api-key\"\\s*:\\s*\"[^\"]+\"", "x-api-key\":\"***\"");
        if (cleaned.length() <= maxLen) return cleaned;
        return cleaned.substring(0, maxLen);
    }

    private String safeMessage(String message) {
        if (message == null || message.isBlank()) return "erro desconhecido";
        if (message.length() > 120) return message.substring(0, 120);
        return message;
    }
}
