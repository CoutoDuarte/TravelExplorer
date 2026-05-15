package Connection.Servlets;

import Connection.Classes.FlightsSearchResult;
import Connection.Classes.HotelSugestao;
import Connection.Classes.PesquisaRequest;
import Connection.Classes.SugestaoViagem;
import Connection.Classes.VooInfo;
import ExternalAPI.ApiConfig;
import ExternalAPI.FlightsClient;
import ExternalAPI.FlightsClient.FlightsApiException;
import ExternalAPI.HotelsClient;
import ExternalAPI.OpenAIClient;
import ExternalAPI.OpenAIClient.IaeduParseDebug;
import ExternalAPI.OpenAIClient.OpenAiApiException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/pesquisar")
public class PesquisaViagemServlet extends HttpServlet {

    private static final String ERRO_GERAL = "Não foi possível concluir a pesquisa neste momento.";
    private static final String ERRO_AUTH = "Para pesquisar e guardar viagens, precisa de iniciar sessão como cliente.";

    private final OpenAIClient openAI = new OpenAIClient();
    private final FlightsClient flights = new FlightsClient();
    private final HotelsClient hotelsClient = new HotelsClient();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp);
    }

    private void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        boolean debug = isDebug(req);
        String debugStep = "read-params";
        String debugMessage = "";
        int flightsCount = 0;

        if (!isClienteLoggedIn(req)) {
            out.print(authRequiredJson());
            return;
        }

        PesquisaRequest pesquisa = PesquisaRequest.from(req);

        debugStep = "validate-params";
        if (!pesquisa.isValid()) {
            if (debug) {
                debugMessage = "Parâmetros obrigatórios em falta ou inválidos";
            }
            out.print(errorJson(debug, debugStep, debugMessage, flightsCount, null, null));
            return;
        }

        FlightsSearchResult flightResult;
        debugStep = "call-flights";
        try {
            flightResult = flights.pesquisarVoos(pesquisa);
            flightsCount = countFlights(flightResult);
        } catch (FlightsApiException e) {
            if (debug) {
                debugMessage = e.getDebugMessage();
            }
            out.print(errorJson(debug, debugStep, debugMessage, flightsCount, null, null));
            return;
        }

        List<VooInfo> voosIda = flightResult == null ? List.of() : flightResult.voosIda;
        List<VooInfo> voosRegresso = flightResult == null ? List.of() : flightResult.voosRegresso;

        debugStep = "call-hotels";
        List<HotelSugestao> serpHotels = hotelsClient.pesquisarHotels(pesquisa);

        SugestaoViagem sugestao;
        debugStep = "call-openai";
        try {
            sugestao = openAI.gerarSugestaoViagem(pesquisa, voosIda, voosRegresso, serpHotels);
        } catch (OpenAiApiException e) {
            if (debug) {
                debugMessage = e.getDebugMessage();
            }
            sugestao = openAI.sugestaoQuandoErroExterno(pesquisa);
        }

        aplicarHoteisResposta(sugestao, serpHotels);

        debugStep = "build-json";
        try {
            out.print(successJson(pesquisa, flightResult, sugestao, debug, flightsCount, serpHotels));
        } catch (Exception e) {
            if (debug) {
                debugMessage = "Erro ao construir JSON";
            }
            out.print(errorJson(debug, debugStep, debugMessage, flightsCount, null, hotelsClient));
        }
    }

    private void aplicarHoteisResposta(SugestaoViagem sugestao, List<HotelSugestao> serpHotels) {
        if (sugestao == null) {
            return;
        }
        if (serpHotels != null && !serpHotels.isEmpty()) {
            int n = Math.min(serpHotels.size(), 8);
            sugestao.hoteisOpcoes = new ArrayList<>(serpHotels.subList(0, n));
            if (sugestao.hotelSugerido == null || sugestao.hotelSugerido.isBlank()) {
                sugestao.hotelSugerido = serpHotels.get(0).nome;
            }
            return;
        }
        if (sugestao.hoteisOpcoes == null) {
            sugestao.hoteisOpcoes = new ArrayList<>();
        }
    }

    private boolean isClienteLoggedIn(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null
                && Boolean.TRUE.equals(session.getAttribute("auth"))
                && "cliente".equals(session.getAttribute("userType"));
    }

    private int countFlights(FlightsSearchResult result) {
        if (result == null) {
            return 0;
        }
        int count = result.voosIda == null ? 0 : result.voosIda.size();
        count += result.voosRegresso == null ? 0 : result.voosRegresso.size();
        return count;
    }

    private boolean isDebug(HttpServletRequest req) {
        return "1".equals(req.getParameter("debug"));
    }

    private String authRequiredJson() {
        return "{\"ok\":false,\"authRequired\":true,\"message\":\""
                + JsonUtil.escape(ERRO_AUTH) + "\"}";
    }

    private String successJson(PesquisaRequest p, FlightsSearchResult flights, SugestaoViagem s,
                               boolean debug, int flightsCount, List<HotelSugestao> serpHotels) {
        List<VooInfo> ida = flights == null || flights.voosIda == null ? List.of() : flights.voosIda;
        List<VooInfo> regresso = flights == null || flights.voosRegresso == null ? List.of() : flights.voosRegresso;
        List<HotelSugestao> hoteisOut = s != null && s.hoteisOpcoes != null
                ? s.hoteisOpcoes
                : List.of();

        StringBuilder json = new StringBuilder();
        json.append("{\"ok\":true");
        json.append(",\"origem\":\"").append(JsonUtil.escape(p.origem)).append("\"");
        json.append(",\"destino\":\"").append(JsonUtil.escape(p.destino)).append("\"");
        json.append(",\"dataPartida\":\"").append(JsonUtil.escape(p.dataPartida)).append("\"");
        json.append(",\"dataRegresso\":\"").append(JsonUtil.escape(p.dataRegresso)).append("\"");
        json.append(",\"adultos\":").append(p.adultos);
        json.append(",\"criancas\":").append(p.criancas);
        json.append(",\"voos\":").append(voosJson(ida));
        json.append(",\"voosIda\":").append(voosJson(ida));
        json.append(",\"voosRegresso\":").append(voosJson(regresso));
        json.append(",\"sugestao\":").append(sugestaoJson(s));
        json.append(",\"hoteisOpcoes\":").append(hoteisOpcoesJson(hoteisOut));
        if (debug) {
            appendDebugFields(json, "build-json", "", flightsCount, null, hotelsClient);
            IaeduParseDebug iaeduDebug = openAI.getLastIaeduDebug();
            json.append(",\"openAiRawLength\":").append(iaeduDebug.rawLength);
            json.append(",\"openAiTextPreview\":\"").append(JsonUtil.escape(iaeduDebug.textPreview)).append("\"");
        }
        json.append("}");
        return json.toString();
    }

    private String voosJson(List<VooInfo> voos) {
        StringBuilder json = new StringBuilder("[");
        if (voos != null) {
            for (int i = 0; i < voos.size(); i++) {
                if (i > 0) json.append(',');
                json.append(vooJson(voos.get(i)));
            }
        }
        json.append(']');
        return json.toString();
    }

    private String vooJson(VooInfo v) {
        return "{"
            + "\"companhia\":\"" + JsonUtil.escape(v.companhia) + "\","
            + "\"numeroVoo\":\"" + JsonUtil.escape(v.numeroVoo) + "\","
            + "\"origem\":\"" + JsonUtil.escape(v.origem) + "\","
            + "\"destino\":\"" + JsonUtil.escape(v.destino) + "\","
            + "\"aeroportoOrigem\":\"" + JsonUtil.escape(v.aeroportoOrigem) + "\","
            + "\"aeroportoDestino\":\"" + JsonUtil.escape(v.aeroportoDestino) + "\","
            + "\"partida\":\"" + JsonUtil.escape(v.partida) + "\","
            + "\"chegada\":\"" + JsonUtil.escape(v.chegada) + "\","
            + "\"duracao\":\"" + JsonUtil.escape(v.duracao) + "\","
            + "\"precoPorPessoa\":" + formatNumber(v.precoPorPessoa) + ","
            + "\"precoTotal\":" + formatNumber(v.precoTotal)
            + "}";
    }

    private String sugestaoJson(SugestaoViagem s) {
        if (s == null) {
            return "{}";
        }
        StringBuilder json = new StringBuilder("{");
        json.append("\"titulo\":\"").append(JsonUtil.escape(s.titulo)).append("\"");
        json.append(",\"descricao\":\"").append(JsonUtil.escape(s.descricao)).append("\"");
        json.append(",\"hotelSugerido\":\"").append(JsonUtil.escape(s.hotelSugerido)).append("\"");
        json.append(",\"transporteSugerido\":\"").append(JsonUtil.escape(s.transporteSugerido)).append("\"");
        json.append(",\"atividades\":").append(atividadesJson(s.atividades));
        json.append(",\"imagemKeywords\":\"").append(JsonUtil.escape(s.imagemKeywords)).append("\"");
        json.append(",\"precoEstimadoTotal\":").append(formatNumber(s.precoEstimadoTotal));
        json.append(",\"hoteisOpcoes\":").append(hoteisOpcoesJson(s.hoteisOpcoes));
        json.append("}");
        return json.toString();
    }

    private String hoteisOpcoesJson(List<HotelSugestao> hoteis) {
        StringBuilder json = new StringBuilder("[");
        if (hoteis != null) {
            for (int i = 0; i < hoteis.size(); i++) {
                if (i > 0) json.append(',');
                HotelSugestao h = hoteis.get(i);
                String descCurta = h.descricaoCurta != null && !h.descricaoCurta.isBlank()
                        ? h.descricaoCurta
                        : (h.descricao != null ? h.descricao : "");
                json.append("{");
                json.append("\"nome\":\"").append(JsonUtil.escape(h.nome)).append("\"");
                json.append(",\"zona\":\"").append(JsonUtil.escape(h.zona)).append("\"");
                json.append(",\"categoria\":\"").append(JsonUtil.escape(h.categoria)).append("\"");
                json.append(",\"descricao\":\"").append(JsonUtil.escape(h.descricao != null ? h.descricao : "")).append("\"");
                json.append(",\"descricaoCurta\":\"").append(JsonUtil.escape(descCurta)).append("\"");
                json.append(",\"precoEstimado\":").append(formatNumber(h.precoEstimado));
                json.append(",\"imagemKeywords\":\"").append(JsonUtil.escape(h.imagemKeywords != null ? h.imagemKeywords : "")).append("\"");
                json.append(",\"imagemUrl\":\"").append(JsonUtil.escape(h.imagemUrl != null ? h.imagemUrl : "")).append("\"");
                json.append(",\"rating\":").append(formatNumber(h.rating));
                json.append(",\"reviews\":").append(h.reviews);
                json.append(",\"amenities\":\"").append(JsonUtil.escape(h.amenities != null ? h.amenities : "")).append("\"");
                json.append(",\"origemDados\":\"").append(JsonUtil.escape(h.origemDados != null ? h.origemDados : "")).append("\"");
                json.append("}");
            }
        }
        json.append(']');
        return json.toString();
    }

    private String atividadesJson(List<String> atividades) {
        StringBuilder json = new StringBuilder("[");
        if (atividades != null) {
            for (int i = 0; i < atividades.size(); i++) {
                if (i > 0) json.append(',');
                json.append('"').append(JsonUtil.escape(atividades.get(i))).append('"');
            }
        }
        json.append(']');
        return json.toString();
    }

    private String errorJson(boolean debug, String debugStep, String debugMessage,
                             int flightsCount, OpenAiApiException openAiError, HotelsClient hc) {
        StringBuilder json = new StringBuilder();
        json.append("{\"ok\":false");
        json.append(",\"message\":\"").append(JsonUtil.escape(ERRO_GERAL)).append("\"");
        if (debug) {
            appendDebugFields(json, debugStep, debugMessage, flightsCount, openAiError, hc);
        }
        json.append("}");
        return json.toString();
    }

    private void appendDebugFields(StringBuilder json, String debugStep, String debugMessage,
                                   int flightsCount, OpenAiApiException openAiError, HotelsClient hc) {
        json.append(",\"debugStep\":\"").append(JsonUtil.escape(debugStep)).append("\"");
        if (debugMessage != null && !debugMessage.isBlank()) {
            json.append(",\"debugMessage\":\"").append(JsonUtil.escape(debugMessage)).append("\"");
        }
        json.append(",\"openAiKeyLoaded\":").append(ApiConfig.hasOpenAIKey());
        json.append(",\"serpApiKeyLoaded\":").append(ApiConfig.hasSerpAPIKey());
        json.append(",\"flightsCount\":").append(flightsCount);
        if (hc != null) {
            json.append(",\"hotelsCount\":").append(hc.getLastHotelCount());
            json.append(",\"hotelsProvider\":\"").append(JsonUtil.escape("serpapi_google_hotels")).append("\"");
            json.append(",\"hotelDebugMessage\":\"").append(JsonUtil.escape(hc.getLastHotelDebugMessage())).append("\"");
        }
        if (openAiError != null) {
            if (openAiError.getHttpStatus() > 0) {
                json.append(",\"openAiStatus\":").append(openAiError.getHttpStatus());
            }
            if (openAiError.getSanitizedBody() != null && !openAiError.getSanitizedBody().isBlank()) {
                json.append(",\"openAiBody\":\"").append(JsonUtil.escape(openAiError.getSanitizedBody())).append("\"");
            }
        }
    }

    private String formatNumber(double value) {
        if (value == (long) value) return String.valueOf((long) value);
        return String.valueOf(value);
    }
}
