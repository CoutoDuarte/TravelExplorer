package Connection.Servlets;

import Connection.Classes.HotelSugestao;
import Connection.Classes.SugestaoViagem;
import Connection.Classes.VooInfo;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.util.List;

public final class BookingJsonHelper {

    private BookingJsonHelper() {
    }

    public static boolean isClienteLoggedIn(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null
                && Boolean.TRUE.equals(session.getAttribute("auth"))
                && "cliente".equals(session.getAttribute("userType"));
    }

    public static String nullSugestaoJson() {
        return "null";
    }

    public static String emptyHoteisJson() {
        return "[]";
    }

    public static String voosJson(List<VooInfo> voos) {
        StringBuilder json = new StringBuilder("[");
        if (voos != null) {
            for (int i = 0; i < voos.size(); i++) {
                if (i > 0) {
                    json.append(',');
                }
                json.append(vooJson(voos.get(i)));
            }
        }
        json.append(']');
        return json.toString();
    }

    public static String vooJson(VooInfo v) {
        if (v == null) {
            return "{}";
        }
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

    public static String hoteisOpcoesJson(List<HotelSugestao> hoteis) {
        StringBuilder json = new StringBuilder("[");
        if (hoteis != null) {
            for (int i = 0; i < hoteis.size(); i++) {
                if (i > 0) {
                    json.append(',');
                }
                json.append(hotelJson(hoteis.get(i)));
            }
        }
        json.append(']');
        return json.toString();
    }

    public static String hotelJson(HotelSugestao h) {
        if (h == null) {
            return "{}";
        }
        String descCurta = h.descricaoCurta != null && !h.descricaoCurta.isBlank()
                ? h.descricaoCurta
                : (h.descricao != null ? h.descricao : "");
        return "{"
            + "\"nome\":\"" + JsonUtil.escape(h.nome) + "\","
            + "\"zona\":\"" + JsonUtil.escape(h.zona) + "\","
            + "\"categoria\":\"" + JsonUtil.escape(h.categoria) + "\","
            + "\"descricao\":\"" + JsonUtil.escape(h.descricao != null ? h.descricao : "") + "\","
            + "\"descricaoCurta\":\"" + JsonUtil.escape(descCurta) + "\","
            + "\"precoEstimado\":" + formatNumber(h.precoEstimado) + ","
            + "\"imagemKeywords\":\"" + JsonUtil.escape(h.imagemKeywords != null ? h.imagemKeywords : "") + "\","
            + "\"imagemUrl\":\"" + JsonUtil.escape(h.imagemUrl != null ? h.imagemUrl : "") + "\","
            + "\"rating\":" + formatNumber(h.rating) + ","
            + "\"reviews\":" + h.reviews + ","
            + "\"amenities\":\"" + JsonUtil.escape(h.amenities != null ? h.amenities : "") + "\","
            + "\"origemDados\":\"" + JsonUtil.escape(h.origemDados != null ? h.origemDados : "") + "\""
            + "}";
    }

    public static String formatNumber(double value) {
        if (value == (long) value) {
            return String.valueOf((long) value);
        }
        return String.valueOf(value);
    }

    public static String sugestaoJson(SugestaoViagem s) {
        if (s == null) {
            return "null";
        }
        StringBuilder json = new StringBuilder("{");
        json.append("\"titulo\":\"").append(JsonUtil.escape(s.titulo)).append("\"");
        json.append(",\"descricao\":\"").append(JsonUtil.escape(s.descricao)).append("\"");
        json.append(",\"hotelSugerido\":\"").append(JsonUtil.escape(s.hotelSugerido)).append("\"");
        json.append(",\"transporteSugerido\":\"").append(JsonUtil.escape(s.transporteSugerido)).append("\"");
        json.append(",\"atividades\":").append(atividadesJson(s.atividades));
        json.append(",\"precoEstimadoTotal\":").append(formatNumber(s.precoEstimadoTotal));
        json.append(",\"resumoFinal\":\"").append(JsonUtil.escape(s.resumoFinal)).append("\"");
        json.append("}");
        return json.toString();
    }

    private static String atividadesJson(java.util.List<String> atividades) {
        StringBuilder json = new StringBuilder("[");
        if (atividades != null) {
            for (int i = 0; i < atividades.size(); i++) {
                if (i > 0) {
                    json.append(',');
                }
                json.append('"').append(JsonUtil.escape(atividades.get(i))).append('"');
            }
        }
        json.append(']');
        return json.toString();
    }
}
