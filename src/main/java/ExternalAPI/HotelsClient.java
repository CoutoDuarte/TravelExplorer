package ExternalAPI;

import Connection.Classes.HotelSugestao;
import Connection.Classes.PesquisaRequest;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.net.URLEncoder;
import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class HotelsClient {

    private static final String ENDPOINT_HINT = "serpapi google_hotels";
    private static final int MAX_HOTELS = 10;
    private static final int LOG_BODY_MAX = 400;

    private static final Map<String, String> IATA_CIDADE = new HashMap<>();

    static {
        IATA_CIDADE.put("OPO", "Porto");
        IATA_CIDADE.put("LIS", "Lisboa");
        IATA_CIDADE.put("FAO", "Faro");
        IATA_CIDADE.put("MAD", "Madrid");
        IATA_CIDADE.put("BCN", "Barcelona");
        IATA_CIDADE.put("CDG", "Paris");
        IATA_CIDADE.put("ORY", "Paris");
        IATA_CIDADE.put("LHR", "Londres");
        IATA_CIDADE.put("LGW", "Londres");
        IATA_CIDADE.put("FCO", "Roma");
        IATA_CIDADE.put("AMS", "Amesterdão");
    }

    private final HttpClient http = HttpClient.newHttpClient();
    private int lastHotelCount;
    private String lastDebugMessage = "";

    public int getLastHotelCount() {
        return lastHotelCount;
    }

    public String getLastHotelDebugMessage() {
        return lastDebugMessage == null ? "" : lastDebugMessage;
    }

    public List<HotelSugestao> pesquisarHotels(PesquisaRequest request) {
        lastHotelCount = 0;
        lastDebugMessage = "";
        List<HotelSugestao> out = new ArrayList<>();
        if (request == null || !request.isValid()) {
            lastDebugMessage = "pedido inválido";
            return out;
        }
        if (!ApiConfig.hasSerpAPIKey()) {
            lastDebugMessage = "SERPAPI key em falta";
            return out;
        }
        String destinoTxt = resolverDestinoParaCidade(request.destino);
        String q = destinoTxt.trim() + " hotels";
        try {
            String url = buildUrl(q, request);
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(35))
                    .GET()
                    .build();
            HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
            String body = resp.body() == null ? "" : resp.body();
            if (resp.statusCode() != 200) {
                logFail(resp.statusCode(), body);
                lastDebugMessage = "HTTP " + resp.statusCode();
                return out;
            }
            out = parseProperties(body);
            lastHotelCount = out.size();
            if (lastHotelCount == 0 && body.contains("\"error\"")) {
                String err = extractErrorMessage(body);
                if (!err.isBlank()) {
                    lastDebugMessage = err.length() > 120 ? err.substring(0, 120) : err;
                } else {
                    lastDebugMessage = "resposta sem hotéis";
                }
            }
        } catch (Exception e) {
            lastDebugMessage = safeMsg(e.getMessage());
        }
        return out;
    }

    private static String resolverDestinoParaCidade(String destino) {
        if (destino == null) {
            return "";
        }
        String t = destino.trim();
        if (t.isEmpty()) {
            return "";
        }
        String iata = t.toUpperCase(Locale.ROOT);
        if (iata.length() == 3 && t.length() <= 4) {
            String city = IATA_CIDADE.get(iata);
            if (city != null) {
                return city;
            }
        }
        return t;
    }

    private static String enc(String v) {
        return URLEncoder.encode(v == null ? "" : v, StandardCharsets.UTF_8);
    }

    private String buildUrl(String q, PesquisaRequest p) {
        return "https://serpapi.com/search.json"
                + "?engine=google_hotels"
                + "&q=" + enc(q)
                + "&check_in_date=" + enc(p.dataPartida)
                + "&check_out_date=" + enc(p.dataRegresso)
                + "&adults=" + p.adultos
                + "&children=" + p.criancas
                + "&currency=EUR"
                + "&gl=pt"
                + "&hl=pt"
                + "&api_key=" + enc(ApiConfig.SERPAPI_KEY);
    }

    private void logFail(int status, String body) {
        System.err.println("[HotelsClient] endpoint=" + ENDPOINT_HINT + " status=" + status);
        System.err.println("[HotelsClient] body=" + truncate(body));
    }

    private String truncate(String s) {
        if (s == null || s.isEmpty()) {
            return "";
        }
        if (s.length() <= LOG_BODY_MAX) {
            return s.replace(ApiConfig.SERPAPI_KEY == null ? "" : ApiConfig.SERPAPI_KEY, "***");
        }
        String redacted = s.replace(ApiConfig.SERPAPI_KEY == null ? "" : ApiConfig.SERPAPI_KEY, "***");
        return redacted.substring(0, LOG_BODY_MAX);
    }

    private static String extractErrorMessage(String json) {
        String key = "\"error\"";
        int i = json.indexOf(key);
        if (i < 0) {
            return "";
        }
        int colon = json.indexOf(':', i);
        if (colon < 0) {
            return "";
        }
        int j = colon + 1;
        while (j < json.length() && Character.isWhitespace(json.charAt(j))) {
            j++;
        }
        if (j < json.length() && json.charAt(j) == '"') {
            StringBuilder sb = new StringBuilder();
            for (int k = j + 1; k < json.length(); k++) {
                char c = json.charAt(k);
                if (c == '"' && json.charAt(k - 1) != '\\') {
                    break;
                }
                sb.append(c);
            }
            return sb.toString();
        }
        return "";
    }

    private List<HotelSugestao> parseProperties(String json) {
        List<HotelSugestao> list = new ArrayList<>();
        if (json == null || json.isBlank()) {
            return list;
        }
        String key = "\"properties\"";
        int idx = json.indexOf(key);
        if (idx < 0) {
            key = "\"properties_results\"";
            idx = json.indexOf(key);
        }
        if (idx < 0) {
            return list;
        }
        int bracket = json.indexOf('[', idx);
        if (bracket < 0) {
            return list;
        }
        int pos = bracket + 1;
        while (pos < json.length() && list.size() < MAX_HOTELS) {
            while (pos < json.length() && Character.isWhitespace(json.charAt(pos))) {
                pos++;
            }
            if (pos >= json.length() || json.charAt(pos) == ']') {
                break;
            }
            if (json.charAt(pos) == ',') {
                pos++;
                continue;
            }
            if (json.charAt(pos) != '{') {
                pos++;
                continue;
            }
            int end = findObjEnd(json, pos);
            if (end < 0) {
                break;
            }
            HotelSugestao h = parseHotel(json.substring(pos, end + 1));
            if (h != null && h.nome != null && !h.nome.isBlank()) {
                list.add(h);
            }
            pos = end + 1;
        }
        return list;
    }

    private static int findObjEnd(String s, int start) {
        int depth = 0;
        boolean inStr = false;
        boolean esc = false;
        for (int i = start; i < s.length(); i++) {
            char c = s.charAt(i);
            if (inStr) {
                if (esc) {
                    esc = false;
                } else if (c == '\\') {
                    esc = true;
                } else if (c == '"') {
                    inStr = false;
                }
                continue;
            }
            if (c == '"') {
                inStr = true;
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

    private HotelSugestao parseHotel(String block) {
        HotelSugestao h = new HotelSugestao();
        h.origemDados = "serpapi_google_hotels";
        h.nome = firstString(block, "\"name\"", "\"hotel_name\"", "\"title\"");
        if (isBlank(h.nome)) {
            return null;
        }
        String desc = firstString(block, "\"description\"", "\"snippet\"");
        h.descricaoCurta = trimLen(desc, 220);
        h.descricao = h.descricaoCurta.isBlank() ? h.nome : h.descricaoCurta;
        h.zona = firstString(block, "\"neighborhood\"");
        if (isBlank(h.zona)) {
            h.zona = coordsLine(block);
        }
        if (isBlank(h.zona)) {
            h.zona = "Zona sugerida";
        }
        int hotelClass = firstIntNear(block, "hotel_class");
        if (hotelClass <= 0) {
            hotelClass = firstIntNear(block, "\"stars\"");
        }
        h.categoria = hotelClass > 0 ? hotelClass + " estrelas" : "Hotel";
        double rate = extractOverallRating(block);
        h.rating = rate > 0 ? rate : 0;
        int rev = extractReviews(block);
        h.reviews = rev;
        h.precoEstimado = extractHotelPriceEuro(block);
        h.amenities = extractAmenitiesLine(block);
        h.imagemUrl = firstThumbnail(block);
        h.imagemKeywords = "";
        return h;
    }

    private static String trimLen(String s, int max) {
        if (s == null) {
            return "";
        }
        String t = s.trim().replace('\n', ' ');
        if (t.length() <= max) {
            return t;
        }
        return t.substring(0, max).trim() + "…";
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String firstString(String block, String... keys) {
        for (String k : keys) {
            int idx = block.indexOf(k);
            if (idx < 0) {
                continue;
            }
            int colon = block.indexOf(':', idx + k.length());
            if (colon < 0) {
                continue;
            }
            int i = colon + 1;
            while (i < block.length() && Character.isWhitespace(block.charAt(i))) {
                i++;
            }
            if (i >= block.length()) {
                continue;
            }
            if (block.charAt(i) == '"') {
                String v = readStr(block, i);
                if (!v.isEmpty()) {
                    return v;
                }
            }
        }
        return "";
    }

    private static int skipPastQuotedString(String s, int quoteStart) {
        if (quoteStart < 0 || quoteStart >= s.length() || s.charAt(quoteStart) != '"') {
            return quoteStart + 1;
        }
        for (int i = quoteStart + 1; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '\\' && i + 1 < s.length()) {
                i++;
                continue;
            }
            if (c == '"') {
                return i + 1;
            }
        }
        return s.length();
    }

    private static String readStr(String s, int quoteStart) {
        if (quoteStart < 0 || quoteStart >= s.length() || s.charAt(quoteStart) != '"') {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (int i = quoteStart + 1; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '\\' && i + 1 < s.length()) {
                sb.append(s.charAt(++i));
                continue;
            }
            if (c == '"') {
                break;
            }
            sb.append(c);
        }
        return sb.toString().trim();
    }

    private static String coordsLine(String block) {
        double lat = firstDoubleAfter(block, "latitude");
        double lng = firstDoubleAfter(block, "longitude");
        if (lat != 0 && lng != 0) {
            return String.format(Locale.US, "%.2f°, %.2f°", lat, lng);
        }
        return "";
    }

    private static double firstDoubleAfter(String block, String field) {
        String key = "\"" + field + "\"";
        int i = block.indexOf(key);
        if (i < 0) {
            return 0;
        }
        int colon = block.indexOf(':', i);
        if (colon < 0) {
            return 0;
        }
        int j = colon + 1;
        while (j < block.length() && Character.isWhitespace(block.charAt(j))) {
            j++;
        }
        int start = j;
        while (j < block.length() && "-0123456789.".indexOf(block.charAt(j)) >= 0) {
            j++;
        }
        try {
            return Double.parseDouble(block.substring(start, j).trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private static int firstIntNear(String block, String key) {
        int i = block.indexOf(key);
        if (i < 0) {
            return 0;
        }
        int colon = block.indexOf(':', i + key.length());
        if (colon < 0 || colon > i + key.length() + 10) {
            colon = block.indexOf(':', i);
        }
        if (colon < 0) {
            return 0;
        }
        int j = colon + 1;
        while (j < block.length() && Character.isWhitespace(block.charAt(j))) {
            j++;
        }
        int start = j;
        while (j < block.length() && Character.isDigit(block.charAt(j))) {
            j++;
        }
        if (start == j) {
            return 0;
        }
        try {
            return Integer.parseInt(block.substring(start, j));
        } catch (Exception e) {
            return 0;
        }
    }

    private static double extractOverallRating(String block) {
        double d = firstDoubleAfter(block, "overall_rating");
        if (d > 0) {
            return d;
        }
        return firstDoubleAfter(block, "rating");
    }

    private static int extractReviews(String block) {
        String key = "\"reviews\"";
        int idx = block.indexOf(key);
        if (idx < 0) {
            return 0;
        }
        int colon = block.indexOf(':', idx + key.length() - 1);
        if (colon < idx) {
            colon = block.indexOf(':', idx);
        }
        if (colon < 0) {
            return 0;
        }
        int j = colon + 1;
        while (j < block.length() && Character.isWhitespace(block.charAt(j))) {
            j++;
        }
        if (j < block.length() && block.charAt(j) == '"') {
            String num = readStr(block, j);
            try {
                return Integer.parseInt(num.replace(",", "").trim());
            } catch (Exception e) {
                return 0;
            }
        }
        int start = j;
        while (j < block.length() && Character.isDigit(block.charAt(j))) {
            j++;
        }
        try {
            return Integer.parseInt(block.substring(start, j).trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private static double extractHotelPriceEuro(String block) {
        double e = extractedLowestIn(block, "total_rate");
        if (e > 0) {
            return e;
        }
        e = extractedLowestIn(block, "rate_per_night");
        if (e > 0) {
            return e;
        }
        return firstDoubleAfter(block, "extracted_lowest");
    }

    private static double extractedLowestIn(String block, String objectKey) {
        String key = "\"" + objectKey + "\"";
        int idx = block.indexOf(key);
        if (idx < 0) {
            return 0;
        }
        int brace = block.indexOf('{', idx);
        if (brace < 0) {
            return 0;
        }
        int end = findObjEnd(block, brace);
        if (end <= brace) {
            return 0;
        }
        String sub = block.substring(brace, end + 1);
        double v = firstDoubleAfter(sub, "extracted_lowest");
        if (v > 0) {
            return v;
        }
        return firstDoubleAfter(sub, "lowest");
    }

    private static String extractAmenitiesLine(String block) {
        int idx = block.indexOf("\"amenities\"");
        if (idx < 0) {
            return "";
        }
        int bracket = block.indexOf('[', idx);
        if (bracket < 0) {
            return "";
        }
        int depth = 0;
        int endBracket = -1;
        for (int i = bracket; i < block.length() && endBracket < 0; i++) {
            char c = block.charAt(i);
            if (c == '[') {
                depth++;
            } else if (c == ']') {
                depth--;
                if (depth == 0) {
                    endBracket = i;
                }
            }
        }
        if (endBracket < 0) {
            return "";
        }
        String arr = block.substring(bracket + 1, endBracket);
        List<String> items = new ArrayList<>();
        int pos = 0;
        while (pos < arr.length() && items.size() < 5) {
            int q = arr.indexOf('"', pos);
            if (q < 0) {
                break;
            }
            String item = readStr(arr, q);
            if (!item.isBlank()) {
                items.add(item);
            }
            pos = skipPastQuotedString(arr, q);
        }
        if (items.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < items.size(); i++) {
            if (i > 0) {
                sb.append(" · ");
            }
            sb.append(items.get(i));
        }
        return trimLen(sb.toString(), 140);
    }

    private static String firstThumbnail(String block) {
        String u = thumbnailFrom(block, "\"thumbnail\"", "\"featured_image\"");
        if (!u.isBlank()) {
            return u;
        }
        int idx = block.indexOf("\"images\"");
        if (idx < 0) {
            idx = block.indexOf("\"photos\"");
        }
        if (idx < 0) {
            return "";
        }
        int bracket = block.indexOf('[', idx);
        if (bracket < 0) {
            return "";
        }
        int end = bracket + 600;
        if (end > block.length()) {
            end = block.length();
        }
        String slice = block.substring(bracket, end);
        u = thumbnailFrom(slice, "\"thumbnail\"", "\"thumbnail_url\"", "\"original_image\"");
        return u;
    }

    private static String thumbnailFrom(String s, String... keys) {
        for (String k : keys) {
            int i = s.indexOf(k);
            if (i < 0) {
                continue;
            }
            int colon = s.indexOf(':', i + k.length());
            if (colon < 0) {
                continue;
            }
            int j = colon + 1;
            while (j < s.length() && Character.isWhitespace(s.charAt(j))) {
                j++;
            }
            if (j >= s.length() || s.charAt(j) != '"') {
                continue;
            }
            String url = readStr(s, j);
            if (url.startsWith("http")) {
                return url;
            }
        }
        return "";
    }

    private static String safeMsg(String m) {
        if (m == null || m.isBlank()) {
            return "indisponível";
        }
        return m.length() > 120 ? m.substring(0, 120) : m;
    }
}
