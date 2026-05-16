package Connection.Classes;

import Connection.Servlets.JsonUtil;

public class CriarSugestaoRequest {
    public String origem;
    public String destino;
    public String dataPartida;
    public String dataRegresso;
    public int adultos;
    public int criancas;
    public VooInfo vooIdaSelecionado;
    public VooInfo vooRegressoSelecionado;
    public HotelSugestao hotelSelecionado;

    public static CriarSugestaoRequest fromJson(String json) {
        CriarSugestaoRequest r = new CriarSugestaoRequest();
        if (json == null || json.isBlank()) {
            return r;
        }
        String body = extractObject(json);
        r.origem = extractString(body, "origem");
        r.destino = extractString(body, "destino");
        r.dataPartida = extractString(body, "dataPartida");
        r.dataRegresso = extractString(body, "dataRegresso");
        r.adultos = (int) Math.round(extractNumber(body, "adultos"));
        r.criancas = (int) Math.round(extractNumber(body, "criancas"));
        r.vooIdaSelecionado = parseVoo(body, "vooIdaSelecionado");
        r.vooRegressoSelecionado = parseVoo(body, "vooRegressoSelecionado");
        r.hotelSelecionado = parseHotel(body, "hotelSelecionado");
        return r;
    }

    public boolean isValid() {
        return notBlank(origem)
                && notBlank(destino)
                && notBlank(dataPartida)
                && notBlank(dataRegresso)
                && adultos > 0
                && vooIdaSelecionado != null
                && notBlank(vooIdaSelecionado.origem);
    }

    private static VooInfo parseVoo(String json, String field) {
        String block = extractNestedObject(json, field);
        if (block.isBlank()) {
            return null;
        }
        VooInfo v = new VooInfo();
        v.companhia = extractString(block, "companhia");
        v.numeroVoo = extractString(block, "numeroVoo");
        v.origem = extractString(block, "origem");
        v.destino = extractString(block, "destino");
        v.aeroportoOrigem = extractString(block, "aeroportoOrigem");
        v.aeroportoDestino = extractString(block, "aeroportoDestino");
        v.partida = extractString(block, "partida");
        v.chegada = extractString(block, "chegada");
        v.duracao = extractString(block, "duracao");
        v.precoPorPessoa = extractNumber(block, "precoPorPessoa");
        v.precoTotal = extractNumber(block, "precoTotal");
        return v;
    }

    private static HotelSugestao parseHotel(String json, String field) {
        String block = extractNestedObject(json, field);
        if (block.isBlank() || block.equals("null")) {
            return null;
        }
        HotelSugestao h = new HotelSugestao();
        h.nome = extractString(block, "nome");
        if (h.nome == null || h.nome.isBlank()) {
            return null;
        }
        h.zona = extractString(block, "zona");
        h.categoria = extractString(block, "categoria");
        h.descricao = extractString(block, "descricao");
        h.descricaoCurta = extractString(block, "descricaoCurta");
        h.precoEstimado = extractNumber(block, "precoEstimado");
        h.imagemUrl = extractString(block, "imagemUrl");
        h.rating = extractNumber(block, "rating");
        h.reviews = (int) Math.round(extractNumber(block, "reviews"));
        h.amenities = extractString(block, "amenities");
        h.origemDados = extractString(block, "origemDados");
        return h;
    }

    private static String extractNestedObject(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) {
            return "";
        }
        int colon = json.indexOf(':', idx);
        if (colon < 0) {
            return "";
        }
        int i = colon + 1;
        while (i < json.length() && Character.isWhitespace(json.charAt(i))) {
            i++;
        }
        if (i >= json.length()) {
            return "";
        }
        if (json.charAt(i) == 'n' && json.regionMatches(i, "null", 0, 4)) {
            return "";
        }
        if (json.charAt(i) != '{') {
            return "";
        }
        int end = findObjectEnd(json, i);
        if (end < 0) {
            return "";
        }
        return json.substring(i, end + 1);
    }

    private static String extractObject(String json) {
        int start = json.indexOf('{');
        int end = json.lastIndexOf('}');
        if (start >= 0 && end > start) {
            return json.substring(start, end + 1);
        }
        return json;
    }

    private static String extractString(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) {
            return "";
        }
        int colon = json.indexOf(':', idx);
        if (colon < 0) {
            return "";
        }
        int i = colon + 1;
        while (i < json.length() && Character.isWhitespace(json.charAt(i))) {
            i++;
        }
        if (i >= json.length() || json.charAt(i) != '"') {
            return "";
        }
        return readQuoted(json, i);
    }

    private static double extractNumber(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) {
            return 0;
        }
        int colon = json.indexOf(':', idx);
        if (colon < 0) {
            return 0;
        }
        int end = colon + 1;
        while (end < json.length() && Character.isWhitespace(json.charAt(end))) {
            end++;
        }
        int stop = end;
        while (stop < json.length()) {
            char c = json.charAt(stop);
            if (c == ',' || c == '}' || c == ']') {
                break;
            }
            stop++;
        }
        try {
            return Double.parseDouble(json.substring(end, stop).trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private static String readQuoted(String json, int quoteStart) {
        StringBuilder sb = new StringBuilder();
        for (int i = quoteStart + 1; i < json.length(); i++) {
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

    private static int findObjectEnd(String json, int start) {
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

    private static boolean notBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }
}
