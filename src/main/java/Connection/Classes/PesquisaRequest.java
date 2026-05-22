package Connection.Classes;

import jakarta.servlet.http.HttpServletRequest;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;

public class PesquisaRequest {
    public String origem;
    public String destino;
    public String dataPartida;
    public String dataRegresso;
    public int adultos;
    public int criancas;

    public static PesquisaRequest from(HttpServletRequest req) {
        PesquisaRequest r = new PesquisaRequest();
        r.origem = firstParam(req, "origem", "origemCidade");
        r.destino = firstParam(req, "destino", "destinoCidade");
        r.dataPartida = firstParam(req, "data_partida", "dataPartida");
        r.dataRegresso = firstParam(req, "data_regresso", "dataRegresso");
        r.adultos = parseIntParam(req, "adultos", "numAdultos", 0);
        r.criancas = parseIntParam(req, "criancas", "numCriancas", 0);
        return r;
    }

    public int totalPassageiros() {
        return Math.max(1, adultos + criancas);
    }

    public boolean isValid() {
        return notBlank(origem)
                && notBlank(destino)
                && notBlank(dataPartida)
                && notBlank(dataRegresso)
                && adultos > 0
                && validateDates() == null;
    }

    public String validateDates() {
        if (!notBlank(dataPartida) || !notBlank(dataRegresso)) {
            return null;
        }
        LocalDate partida;
        LocalDate regresso;
        try {
            partida = LocalDate.parse(trimDate(dataPartida));
            regresso = LocalDate.parse(trimDate(dataRegresso));
        } catch (DateTimeParseException e) {
            return "invalid";
        }
        LocalDate today = LocalDate.now();
        if (partida.isBefore(today)) {
            return "partida_passado";
        }
        if (regresso.isBefore(partida)) {
            return "regresso_antes";
        }
        return null;
    }

    public static String messageForDateError(String code) {
        if ("partida_passado".equals(code)) {
            return "A data de partida não pode ser anterior à data de hoje.";
        }
        if ("regresso_antes".equals(code)) {
            return "A data de regresso não pode ser anterior à data de partida.";
        }
        return "As datas introduzidas não são válidas.";
    }

    private static String trimDate(String iso) {
        String v = iso.trim();
        return v.length() >= 10 ? v.substring(0, 10) : v;
    }

    private static String firstParam(HttpServletRequest req, String primary, String alternate) {
        String v = trim(req.getParameter(primary));
        if (notBlank(v)) return v;
        return trim(req.getParameter(alternate));
    }

    private static int parseIntParam(HttpServletRequest req, String primary, String alternate, int defaultValue) {
        String v = firstParam(req, primary, alternate);
        if (!notBlank(v)) return defaultValue;
        try {
            return Integer.parseInt(v.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private static boolean notBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }
}
