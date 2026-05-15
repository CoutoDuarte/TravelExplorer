package Connection.Classes;

import jakarta.servlet.http.HttpServletRequest;

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
                && adultos > 0;
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
