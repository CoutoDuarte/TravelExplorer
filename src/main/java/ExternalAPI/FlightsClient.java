package ExternalAPI;

import Connection.Classes.FlightsSearchResult;
import Connection.Classes.PesquisaRequest;
import Connection.Classes.VooInfo;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class FlightsClient {

    private static final String ENDPOINT_NAME = "serpapi.com/search.json?engine=google_flights";
    private static final int MAX_VOOS = 8;
    private static final int LOG_BODY_MAX = 500;

    private static final Map<String, String> CODIGOS_AEROPORTO = new HashMap<>();

    static {
        CODIGOS_AEROPORTO.put("lisboa", "LIS");
        CODIGOS_AEROPORTO.put("porto", "OPO");
        CODIGOS_AEROPORTO.put("faro", "FAO");
        CODIGOS_AEROPORTO.put("funchal", "FNC");
        CODIGOS_AEROPORTO.put("madeira", "FNC");
        CODIGOS_AEROPORTO.put("barcelona", "BCN");
        CODIGOS_AEROPORTO.put("madrid", "MAD");
        CODIGOS_AEROPORTO.put("paris", "CDG");
        CODIGOS_AEROPORTO.put("londres", "LHR");
        CODIGOS_AEROPORTO.put("roma", "FCO");
        CODIGOS_AEROPORTO.put("milao", "MXP");
        CODIGOS_AEROPORTO.put("berlim", "BER");
        CODIGOS_AEROPORTO.put("amesterdao", "AMS");
        CODIGOS_AEROPORTO.put("dublin", "DUB");
        CODIGOS_AEROPORTO.put("nova iorque", "JFK");
        CODIGOS_AEROPORTO.put("new york", "JFK");
        CODIGOS_AEROPORTO.put("frankfurt", "FRA");
        CODIGOS_AEROPORTO.put("heathrow", "LHR");
        CODIGOS_AEROPORTO.put("charles de gaulle", "CDG");
    }

    private final HttpClient http = HttpClient.newHttpClient();

    public static class FlightsApiException extends Exception {
        private final String debugMessage;

        public FlightsApiException(String debugMessage) {
            super(debugMessage);
            this.debugMessage = debugMessage;
        }

        public String getDebugMessage() {
            return debugMessage;
        }
    }

    public FlightsSearchResult pesquisarVoos(PesquisaRequest request) throws FlightsApiException {
        if (request == null || !request.isValid()) {
            throw new FlightsApiException("Pedido de voos inválido");
        }
        if (!ApiConfig.hasSerpAPIKey()) {
            throw new FlightsApiException("SERPAPI key em falta");
        }

        String origemIata = resolverCodigoAeroporto(request.origem);
        String destinoIata = resolverCodigoAeroporto(request.destino);
        int passageiros = request.totalPassageiros();
        FlightsSearchResult result = new FlightsSearchResult();

        try {
            String idaJson = fetchOneWay(
                    origemIata, destinoIata, request.dataPartida,
                    request.adultos, request.criancas);
            result.voosIda = parseOneWayFlights(idaJson, passageiros);
        } catch (FlightsApiException e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw new FlightsApiException("Erro de ligação SERPAPI (ida): " + safeMessage(e.getMessage()));
        }

        try {
            String regressoJson = fetchOneWay(
                    destinoIata, origemIata, request.dataRegresso,
                    request.adultos, request.criancas);
            result.voosRegresso = parseOneWayFlights(regressoJson, passageiros);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }

    private String fetchOneWay(String origemIATA, String destinoIATA, String outboundDate,
                             int adultos, int criancas) throws Exception {
        String url = "https://serpapi.com/search.json"
                + "?engine=google_flights"
                + "&type=2"
                + "&departure_id=" + enc(origemIATA)
                + "&arrival_id=" + enc(destinoIATA)
                + "&outbound_date=" + enc(outboundDate)
                + "&adults=" + adultos
                + "&children=" + criancas
                + "&currency=EUR"
                + "&hl=pt"
                + "&api_key=" + enc(ApiConfig.SERPAPI_KEY);

        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(30))
                .GET()
                .build();

        HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
        String responseBody = resp.body() == null ? "" : resp.body();
        if (resp.statusCode() != 200) {
            logHttpFailure(resp.statusCode(), responseBody);
            throw new FlightsApiException("SERPAPI HTTP " + resp.statusCode());
        }
        return responseBody;
    }

    private void logHttpFailure(int statusCode, String body) {
        System.err.println("[FlightsClient] endpoint=" + ENDPOINT_NAME + " status=" + statusCode);
        System.err.println("[FlightsClient] body=" + truncateBody(body));
    }

    private List<VooInfo> parseOneWayFlights(String json, int passageiros) {
        List<VooInfo> voos = new ArrayList<>();
        if (json == null || json.isBlank()) {
            return voos;
        }
        appendOptionsToList(json, "best_flights", voos, passageiros);
        if (voos.size() < MAX_VOOS) {
            appendOptionsToList(json, "other_flights", voos, passageiros);
        }
        return voos;
    }

    private void appendOptionsToList(String json, String arrayName, List<VooInfo> voos, int passageiros) {
        int arrayStart = findArrayStart(json, arrayName);
        if (arrayStart < 0) return;
        int i = arrayStart + 1;
        while (i < json.length() && voos.size() < MAX_VOOS) {
            while (i < json.length() && Character.isWhitespace(json.charAt(i))) i++;
            if (i >= json.length() || json.charAt(i) == ']') return;
            if (json.charAt(i) == ',') {
                i++;
                continue;
            }
            if (json.charAt(i) != '{') {
                i++;
                continue;
            }
            int end = findObjectEnd(json, i);
            if (end < 0) return;
            VooInfo voo = parseFirstFlightInOption(json.substring(i, end + 1), passageiros);
            if (voo != null) {
                voos.add(voo);
            }
            i = end + 1;
        }
    }

    private VooInfo parseFirstFlightInOption(String block, int passageiros) {
        double optionPrice = extractNumber(block, "price");
        java.util.List<VooInfo> segments = parseAllFlightSegments(block, optionPrice, passageiros);
        if (segments.isEmpty()) {
            return null;
        }
        VooInfo first = segments.get(0);
        VooInfo last = segments.get(segments.size() - 1);
        VooInfo v = new VooInfo();
        v.companhia = first.companhia;
        v.numeroVoo = first.numeroVoo;
        v.origem = first.origem;
        v.destino = last.destino;
        v.aeroportoOrigem = first.aeroportoOrigem;
        v.aeroportoDestino = last.aeroportoDestino;
        v.partida = first.partida;
        v.chegada = last.chegada;
        v.duracao = first.duracao;
        v.precoTotal = optionPrice;
        v.precoPorPessoa = passageiros > 0 ? v.precoTotal / passageiros : v.precoTotal;
        v.segmentos = segments;
        v.numEscalas = Math.max(0, segments.size() - 1);
        return v;
    }

    private java.util.List<VooInfo> parseAllFlightSegments(String block, double optionPrice, int passageiros) {
        java.util.List<VooInfo> segments = new java.util.ArrayList<>();
        int flightsIdx = block.indexOf("\"flights\"");
        if (flightsIdx < 0) {
            return segments;
        }
        int arrayStart = block.indexOf('[', flightsIdx);
        if (arrayStart < 0) {
            return segments;
        }
        int pos = arrayStart + 1;
        while (pos < block.length()) {
            while (pos < block.length() && Character.isWhitespace(block.charAt(pos))) {
                pos++;
            }
            if (pos >= block.length() || block.charAt(pos) == ']') {
                break;
            }
            if (block.charAt(pos) == ',') {
                pos++;
                continue;
            }
            if (block.charAt(pos) != '{') {
                pos++;
                continue;
            }
            int flightEnd = findObjectEnd(block, pos);
            if (flightEnd < 0) {
                break;
            }
            VooInfo seg = parseFlightSegment(block.substring(pos, flightEnd + 1), optionPrice, passageiros);
            if (seg != null) {
                segments.add(seg);
            }
            pos = flightEnd + 1;
        }
        return segments;
    }

    private int findArrayStart(String json, String arrayName) {
        String key = "\"" + arrayName + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) return -1;
        return json.indexOf('[', idx);
    }

    private VooInfo parseFlightSegment(String flight, double optionPrice, int passageiros) {
        VooInfo v = new VooInfo();
        v.companhia = extractString(flight, "airline");
        v.numeroVoo = extractString(flight, "flight_number");
        v.aeroportoOrigem = extractNestedString(flight, "departure_airport", "name");
        v.origem = extractNestedString(flight, "departure_airport", "id");
        v.partida = extractNestedString(flight, "departure_airport", "time");
        v.aeroportoDestino = extractNestedString(flight, "arrival_airport", "name");
        v.destino = extractNestedString(flight, "arrival_airport", "id");
        v.chegada = extractNestedString(flight, "arrival_airport", "time");
        int duracaoMin = extractInt(flight, "duration");
        v.duracao = formatDuracao(duracaoMin);
        v.precoTotal = optionPrice;
        v.precoPorPessoa = passageiros > 0 ? v.precoTotal / passageiros : v.precoTotal;
        if (v.origem.isEmpty() && v.destino.isEmpty()) return null;
        return v;
    }

    private int findObjectEnd(String json, int start) {
        int depth = 0;
        for (int i = start; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '{') depth++;
            else if (c == '}') {
                depth--;
                if (depth == 0) return i;
            }
        }
        return -1;
    }

    private String extractString(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) return "";
        int colon = json.indexOf(':', idx);
        int q1 = json.indexOf('"', colon + 1);
        if (q1 < 0) return "";
        int q2 = json.indexOf('"', q1 + 1);
        if (q2 < 0) return "";
        return json.substring(q1 + 1, q2);
    }

    private String extractNestedString(String json, String object, String field) {
        String objectKey = "\"" + object + "\"";
        int idx = json.indexOf(objectKey);
        if (idx < 0) return "";
        int start = json.indexOf('{', idx);
        if (start < 0) return "";
        int end = findObjectEnd(json, start);
        if (end < 0) return "";
        return extractString(json.substring(start, end + 1), field);
    }

    private int extractInt(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) return 0;
        int colon = json.indexOf(':', idx);
        if (colon < 0) return 0;
        int end = colon + 1;
        while (end < json.length() && Character.isWhitespace(json.charAt(end))) end++;
        int stop = end;
        while (stop < json.length()) {
            char c = json.charAt(stop);
            if (c == ',' || c == '}' || c == ']') break;
            stop++;
        }
        try {
            return (int) Math.round(Double.parseDouble(json.substring(end, stop).trim()));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private double extractNumber(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) return 0;
        int colon = json.indexOf(':', idx);
        if (colon < 0) return 0;
        int end = colon + 1;
        while (end < json.length() && Character.isWhitespace(json.charAt(end))) end++;
        int stop = end;
        while (stop < json.length()) {
            char c = json.charAt(stop);
            if (c == ',' || c == '}' || c == ']') break;
            stop++;
        }
        try {
            return Double.parseDouble(json.substring(end, stop).trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String formatDuracao(int minutos) {
        if (minutos <= 0) return "";
        int h = minutos / 60;
        int m = minutos % 60;
        if (h > 0 && m > 0) return h + "h " + m + "min";
        if (h > 0) return h + "h";
        return m + "min";
    }

    private String resolverCodigoAeroporto(String cidade) {
        if (cidade == null) return "";
        String trimmed = cidade.trim();
        if (trimmed.length() == 3 && trimmed.equals(trimmed.toUpperCase(Locale.ROOT))) {
            return trimmed;
        }
        String key = trimmed.toLowerCase(Locale.ROOT);
        String mapped = CODIGOS_AEROPORTO.get(key);
        if (mapped != null) return mapped;
        int comma = key.indexOf(',');
        if (comma > 0) {
            mapped = CODIGOS_AEROPORTO.get(key.substring(0, comma).trim());
            if (mapped != null) return mapped;
        }
        return trimmed.toUpperCase(Locale.ROOT);
    }

    private String enc(String s) {
        return URLEncoder.encode(s == null ? "" : s, StandardCharsets.UTF_8);
    }

    private String truncateBody(String body) {
        if (body == null || body.isEmpty()) return "";
        String cleaned = body.replaceAll("api_key=[^&\\s\"]+", "api_key=***");
        if (cleaned.length() <= LOG_BODY_MAX) return cleaned;
        return cleaned.substring(0, LOG_BODY_MAX);
    }

    private String safeMessage(String message) {
        if (message == null || message.isBlank()) return "erro desconhecido";
        if (message.length() > 120) return message.substring(0, 120);
        return message;
    }
}
