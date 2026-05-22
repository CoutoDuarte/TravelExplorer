package ExternalAPI;

import Connection.Classes.AirportSuggestion;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

public class FlightAutocompleteClient {

    private static final int MAX_RESULTS = 8;
    private static final int LOG_BODY_MAX = 500;

    private final HttpClient http = HttpClient.newHttpClient();

    public List<AirportSuggestion> autocomplete(String query) {
        if (query == null || query.trim().length() < 2) {
            return List.of();
        }
        if (!ApiConfig.hasSerpAPIKey()) {
            return List.of();
        }

        String q = query.trim();
        String url = "https://serpapi.com/search.json"
                + "?engine=google_flights_autocomplete"
                + "&q=" + enc(q)
                + "&hl=en"
                + "&gl=pt"
                + "&exclude_regions=true"
                + "&api_key=" + enc(ApiConfig.SERPAPI_KEY);

        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(15))
                    .GET()
                    .build();
            HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
            String body = resp.body() == null ? "" : resp.body();
            if (resp.statusCode() != 200) {
                logFailure(resp.statusCode(), body);
                return List.of();
            }
            return parseSuggestions(body);
        } catch (Exception e) {
            e.printStackTrace();
            return List.of();
        }
    }

    private List<AirportSuggestion> parseSuggestions(String json) {
        List<AirportSuggestion> results = new ArrayList<>();
        Set<String> seen = new LinkedHashSet<>();
        int suggestionsStart = findArrayStart(json, "suggestions");
        if (suggestionsStart < 0) {
            return results;
        }
        int pos = suggestionsStart + 1;
        while (pos < json.length() && results.size() < MAX_RESULTS) {
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
            int suggestionEnd = findObjectEnd(json, pos);
            if (suggestionEnd < 0) {
                break;
            }
            String suggestionBlock = json.substring(pos, suggestionEnd + 1);
            collectAirportsFromBlock(suggestionBlock, results, seen);
            pos = suggestionEnd + 1;
        }
        return results;
    }

    private void collectAirportsFromBlock(String block, List<AirportSuggestion> results, Set<String> seen) {
        int airportsStart = findArrayStart(block, "airports");
        if (airportsStart < 0) {
            return;
        }
        int pos = airportsStart + 1;
        while (pos < block.length() && results.size() < MAX_RESULTS) {
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
            int airportEnd = findObjectEnd(block, pos);
            if (airportEnd < 0) {
                break;
            }
            String airportBlock = block.substring(pos, airportEnd + 1);
            AirportSuggestion suggestion = parseAirport(airportBlock);
            if (suggestion != null) {
                String code = suggestion.code.toUpperCase(Locale.ROOT);
                if (code.length() == 3 && seen.add(code)) {
                    results.add(suggestion);
                }
            }
            pos = airportEnd + 1;
        }
    }

    private AirportSuggestion parseAirport(String block) {
        String code = extractString(block, "id");
        if (code == null || code.isBlank()) {
            return null;
        }
        code = code.trim().toUpperCase(Locale.ROOT);
        if (code.length() != 3) {
            return null;
        }
        String name = extractString(block, "name");
        String city = extractString(block, "city");
        if (name == null || name.isBlank()) {
            name = city != null ? city : code;
        }
        if (city == null || city.isBlank()) {
            city = name;
        }
        String label = buildLabel(city, name, code);
        return new AirportSuggestion(code, name.trim(), city.trim(), label);
    }

    private String buildLabel(String city, String name, String code) {
        String c = city != null ? city.trim() : "";
        String n = name != null ? name.trim() : "";
        if (!c.isEmpty() && !n.isEmpty() && !c.equalsIgnoreCase(n)) {
            return c + " · " + n + " (" + code + ")";
        }
        if (!n.isEmpty()) {
            return n + " (" + code + ")";
        }
        if (!c.isEmpty()) {
            return c + " (" + code + ")";
        }
        return code;
    }

    private String extractString(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) {
            return "";
        }
        int colon = json.indexOf(':', idx);
        if (colon < 0) {
            return "";
        }
        int start = colon + 1;
        while (start < json.length() && Character.isWhitespace(json.charAt(start))) {
            start++;
        }
        if (start >= json.length() || json.charAt(start) != '"') {
            return "";
        }
        start++;
        StringBuilder sb = new StringBuilder();
        boolean escape = false;
        for (int i = start; i < json.length(); i++) {
            char c = json.charAt(i);
            if (escape) {
                sb.append(c);
                escape = false;
                continue;
            }
            if (c == '\\') {
                escape = true;
                continue;
            }
            if (c == '"') {
                return sb.toString();
            }
            sb.append(c);
        }
        return "";
    }

    private int findArrayStart(String json, String arrayName) {
        String key = "\"" + arrayName + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) {
            return -1;
        }
        return json.indexOf('[', idx);
    }

    private int findObjectEnd(String json, int start) {
        int depth = 0;
        boolean inString = false;
        boolean escape = false;
        for (int i = start; i < json.length(); i++) {
            char c = json.charAt(i);
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

    private String enc(String s) {
        return URLEncoder.encode(s == null ? "" : s, StandardCharsets.UTF_8);
    }

    private void logFailure(int statusCode, String body) {
        System.err.println("[FlightAutocompleteClient] status=" + statusCode);
        System.err.println("[FlightAutocompleteClient] body=" + truncate(body));
    }

    private String truncate(String body) {
        if (body == null || body.isEmpty()) {
            return "";
        }
        String cleaned = body.replaceAll("api_key=[^&\\s\"]+", "api_key=***");
        if (cleaned.length() <= LOG_BODY_MAX) {
            return cleaned;
        }
        return cleaned.substring(0, LOG_BODY_MAX);
    }
}
