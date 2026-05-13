package ExternalAPI;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

public class OpenAIClient {

    private static final String ENDPOINT = "https://api.iaedu.pt/agent-chat//api/v1/agent/cmamvd3n40000c801qeacoad2/stream";
    private static final String MODEL    = "gpt-4o"; // bom custo/desempenho

    private final HttpClient http = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(15))
            .build();

    /**
     * Pede ao ChatGPT um JSON com IATA + alojamento + transfer.
     * Retorna a string JSON crua (a parsear no servlet).
     */
    public String pesquisarContexto(String origem, String destino,
                                    int adultos, int criancas,
                                    String dataPartida, String dataRegresso) throws Exception {

        String userPrompt = String.format(
            "Para uma viagem de %s para %s, de %s a %s, para %d adulto(s) e %d criança(s), devolve APENAS um JSON válido com a seguinte estrutura exata, sem texto adicional:%n" +
            "{%n" +
            "  \"origemIATA\": \"<código IATA do aeroporto mais próximo da origem>\",%n" +
            "  \"destinoIATA\": \"<código IATA do aeroporto mais próximo do destino>\",%n" +
            "  \"alojamento\": {%n" +
            "     \"nome\": \"<nome típico de hotel 3-4 estrelas no destino>\",%n" +
            "     \"tipo\": \"hotel\",%n" +
            "     \"precoPorNoite\": <preço médio em EUR por quarto>,%n" +
            "     \"precoTotal\": <preço total estimado para o nº de pessoas e noites>,%n" +
            "     \"moeda\": \"EUR\",%n" +
            "     \"moradaAprox\": \"<zona típica para turistas>\"%n" +
            "  },%n" +
            "  \"transfer\": {%n" +
            "     \"tipo\": \"<taxi/metro/comboio mais comum>\",%n" +
            "     \"duracaoMin\": <minutos>,%n" +
            "     \"precoEstimado\": <preço em EUR>,%n" +
            "     \"moeda\": \"EUR\",%n" +
            "     \"descricao\": \"<breve descrição do percurso aeroporto-alojamento>\"%n" +
            "  }%n" +
            "}",
            origem, destino, dataPartida, dataRegresso, adultos, criancas
        );

        String body = "{"
            + "\"model\":\"" + MODEL + "\","
            + "\"response_format\":{\"type\":\"json_object\"},"
            + "\"messages\":["
            +   "{\"role\":\"system\",\"content\":\"És um assistente de viagens. Responde apenas com JSON válido.\"},"
            +   "{\"role\":\"user\",\"content\":\"" + escapeJson(userPrompt) + "\"}"
            + "],"
            + "\"temperature\":0.3"
            + "}";

        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(ENDPOINT))
                .timeout(Duration.ofSeconds(30))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + ApiConfig.OPENAI_API_KEY)
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();

        HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
        if (resp.statusCode() != 200) {
            throw new RuntimeException("OpenAI error " + resp.statusCode() + ": " + resp.body());
        }

        // Extrai content do JSON de resposta (parse simples; recomendo Gson)
        return extractContent(resp.body());
    }

    private String extractContent(String responseJson) {
        // Resposta da OpenAI: {"choices":[{"message":{"content":"...JSON..."}}]}
        int contentIdx = responseJson.indexOf("\"content\":\"");
        if (contentIdx < 0) throw new RuntimeException("content não encontrado");
        int start = contentIdx + "\"content\":\"".length();
        StringBuilder sb = new StringBuilder();
        for (int i = start; i < responseJson.length(); i++) {
            char c = responseJson.charAt(i);
            if (c == '\\' && i + 1 < responseJson.length()) {
                char next = responseJson.charAt(++i);
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

    private String escapeJson(String s) {
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}