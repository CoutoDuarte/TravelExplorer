package Connection.Classes;

import Connection.Servlets.JsonUtil;

import java.util.ArrayList;
import java.util.List;

public class SugestaoViagem {
    public String titulo;
    public String descricao;
    public String hotelSugerido;
    public String transporteSugerido;
    public List<String> atividades = new ArrayList<>();
    public String imagemKeywords;
    public double precoEstimadoTotal;
    public String resumoFinal;
    public List<HotelSugestao> hoteisOpcoes = new ArrayList<>();

    public static SugestaoViagem fromJson(String json) {
        SugestaoViagem s = new SugestaoViagem();
        if (json == null || json.isBlank()) return s;
        String body = extractObject(json);
        s.titulo = extractStringField(body, "titulo");
        s.descricao = extractStringField(body, "descricao");
        s.hotelSugerido = extractStringField(body, "hotelSugerido");
        s.transporteSugerido = extractStringField(body, "transporteSugerido");
        s.imagemKeywords = extractStringField(body, "imagemKeywords");
        s.precoEstimadoTotal = extractNumberField(body, "precoEstimadoTotal");
        s.resumoFinal = extractStringField(body, "resumoFinal");
        s.atividades = extractStringArray(body, "atividades");
        s.hoteisOpcoes = extractHotelArray(body, "hoteisOpcoes");
        if ((s.hotelSugerido == null || s.hotelSugerido.isBlank()) && !s.hoteisOpcoes.isEmpty()) {
            s.hotelSugerido = s.hoteisOpcoes.get(0).nome;
        }
        return s;
    }

    private static String extractObject(String json) {
        int start = json.indexOf('{');
        int end = json.lastIndexOf('}');
        if (start >= 0 && end > start) return json.substring(start, end + 1);
        return json;
    }

    private static String extractStringField(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) return "";
        int colon = json.indexOf(':', idx + key.length());
        if (colon < 0) return "";
        int i = colon + 1;
        while (i < json.length() && Character.isWhitespace(json.charAt(i))) i++;
        if (i >= json.length()) return "";
        if (json.charAt(i) == '"') {
            StringBuilder sb = new StringBuilder();
            for (i++; i < json.length(); i++) {
                char c = json.charAt(i);
                if (c == '\\' && i + 1 < json.length()) {
                    char next = json.charAt(++i);
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
            return JsonUtil.unescapeJsonText(sb.toString().trim());
        }
        int end = i;
        while (end < json.length() && json.charAt(end) != ',' && json.charAt(end) != '}') end++;
        return JsonUtil.unescapeJsonText(json.substring(i, end).trim());
    }

    private static double extractNumberField(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) return 0;
        int colon = json.indexOf(':', idx + key.length());
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

    private static List<String> extractStringArray(String json, String field) {
        List<String> items = new ArrayList<>();
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) return items;
        int start = json.indexOf('[', idx);
        int end = json.indexOf(']', start);
        if (start < 0 || end < 0) return items;
        String arrayBody = json.substring(start + 1, end);
        int i = 0;
        while (i < arrayBody.length()) {
            int q = arrayBody.indexOf('"', i);
            if (q < 0) break;
            StringBuilder sb = new StringBuilder();
            for (i = q + 1; i < arrayBody.length(); i++) {
                char c = arrayBody.charAt(i);
                if (c == '\\' && i + 1 < arrayBody.length()) {
                    char next = arrayBody.charAt(++i);
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
            String value = JsonUtil.unescapeJsonText(sb.toString().trim());
            if (!value.isEmpty()) items.add(value);
            i++;
        }
        return items;
    }

    private static List<HotelSugestao> extractHotelArray(String json, String field) {
        List<HotelSugestao> hotels = new ArrayList<>();
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) return hotels;
        int start = json.indexOf('[', idx);
        if (start < 0) return hotels;
        int pos = start + 1;
        while (pos < json.length()) {
            while (pos < json.length() && Character.isWhitespace(json.charAt(pos))) pos++;
            if (pos >= json.length() || json.charAt(pos) == ']') break;
            if (json.charAt(pos) == ',') {
                pos++;
                continue;
            }
            if (json.charAt(pos) != '{') {
                pos++;
                continue;
            }
            int end = findObjectEnd(json, pos);
            if (end < 0) break;
            String block = json.substring(pos, end + 1);
            HotelSugestao h = new HotelSugestao();
            h.nome = extractStringField(block, "nome");
            h.zona = extractStringField(block, "zona");
            h.categoria = extractStringField(block, "categoria");
            h.descricao = extractStringField(block, "descricao");
            h.descricaoCurta = extractStringField(block, "descricaoCurta");
            if (h.descricao == null || h.descricao.isBlank()) {
                h.descricao = h.descricaoCurta;
            }
            h.precoEstimado = extractNumberField(block, "precoEstimado");
            h.imagemKeywords = extractStringField(block, "imagemKeywords");
            h.imagemUrl = extractStringField(block, "imagemUrl");
            h.rating = extractNumberField(block, "rating");
            h.reviews = (int) Math.round(extractNumberField(block, "reviews"));
            h.amenities = extractStringField(block, "amenities");
            h.origemDados = extractStringField(block, "origemDados");
            if (h.nome != null && !h.nome.isBlank()) {
                hotels.add(h);
            }
            pos = end + 1;
        }
        return hotels;
    }

    private static int findObjectEnd(String json, int start) {
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
}
