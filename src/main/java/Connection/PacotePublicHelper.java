package Connection;

import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import Connection.Classes.Pacote;
import Connection.Classes.Promocao;
import Connection.Classes.Viagens;

import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public final class PacotePublicHelper {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd MMM yyyy", Locale.forLanguageTag("pt-PT"));
    private static final Pattern DISCOUNT_PATTERN = Pattern.compile("(?i)(?:desconto\\s+de\\s+)?(\\d{1,2})\\s*%");

    private PacotePublicHelper() {
    }

    public static final class PromoPrice {
        public final boolean hasPromo;
        public final int discountPercent;
        public final float originalPrice;
        public final float discountedPrice;

        public PromoPrice(boolean hasPromo, int discountPercent, float originalPrice, float discountedPrice) {
            this.hasPromo = hasPromo;
            this.discountPercent = discountPercent;
            this.originalPrice = originalPrice;
            this.discountedPrice = discountedPrice;
        }
    }

    public static boolean isPubliclyVisible(Pacote p) {
        if (p == null) {
            return false;
        }
        if (p.getIdReserva() > 0) {
            return false;
        }
        String tipo = p.getTipo();
        return tipo != null && !tipo.isBlank() && !"Reserva".equalsIgnoreCase(tipo.trim());
    }

    public static String resolveImageSrc(Pacote p, String contextPath) {
        if (p == null || contextPath == null) {
            return null;
        }
        String raw = p.getImagemUrl();
        if (raw == null || raw.isBlank()) {
            return null;
        }
        String u = raw.trim();
        if (u.startsWith("http://") || u.startsWith("https://")) {
            return u;
        }
        if (u.startsWith("/")) {
            return contextPath + u;
        }
        return contextPath + "/" + u;
    }

    public static int gradientSeed(int idPacote) {
        return Math.max(1, (idPacote % 3) + 1);
    }

    public static int parseDiscountPercent(String condicao) {
        if (condicao == null || condicao.isBlank()) {
            return 0;
        }
        Matcher m = DISCOUNT_PATTERN.matcher(condicao.trim());
        if (m.find()) {
            try {
                int pct = Integer.parseInt(m.group(1));
                if (pct > 0 && pct < 100) {
                    return pct;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        return 0;
    }

    public static PromoPrice priceForPacote(Pacote pacote, Promocao promo) {
        if (pacote == null) {
            return new PromoPrice(false, 0, 0f, 0f);
        }
        float base = pacote.getPrecoBase();
        if (promo == null) {
            return new PromoPrice(false, 0, base, base);
        }
        int pct = parseDiscountPercent(promo.getCondicao());
        if (pct <= 0) {
            return new PromoPrice(false, 0, base, base);
        }
        float discounted = base - (base * pct / 100f);
        if (discounted < 0) {
            discounted = 0;
        }
        return new PromoPrice(true, pct, base, discounted);
    }

    public static Map<Integer, Promocao> mapActivePromosByPacote(List<Promocao> promocoes) {
        Map<Integer, Promocao> map = new HashMap<>();
        if (promocoes == null) {
            return map;
        }
        for (Promocao promo : promocoes) {
            if (promo == null || promo.getIdPacote() <= 0) {
                continue;
            }
            map.putIfAbsent(promo.getIdPacote(), promo);
        }
        return map;
    }

    public static String formatDesdePreco(float preco, DecimalFormat df) {
        return "Desde " + df.format(preco) + " €";
    }

    public static String formatPrecoCard(PromoPrice pp, DecimalFormat df) {
        if (pp == null) {
            return "";
        }
        if (pp.hasPromo) {
            return formatDesdePreco(pp.discountedPrice, df);
        }
        return formatDesdePreco(pp.originalPrice, df);
    }

    public static String formatPrecoOriginalRiscado(PromoPrice pp, DecimalFormat df) {
        if (pp == null || !pp.hasPromo) {
            return "";
        }
        return df.format(pp.originalPrice) + " €";
    }

    public static String promoBadge(PromoPrice pp) {
        if (pp == null || !pp.hasPromo) {
            return "";
        }
        return "-" + pp.discountPercent + "%";
    }

    public static String routeFromViagens(List<Viagens> viagens) {
        if (viagens == null || viagens.isEmpty()) {
            return "";
        }
        String origem = "";
        String destino = "";
        for (Viagens v : viagens) {
            if (v == null) {
                continue;
            }
            if (origem.isEmpty() && v.getOrigem() != null && !v.getOrigem().isBlank()) {
                origem = v.getOrigem().trim();
            }
            if (v.getDestino() != null && !v.getDestino().isBlank()) {
                destino = v.getDestino().trim();
            }
        }
        if (!origem.isEmpty() && !destino.isEmpty() && !origem.equals(destino)) {
            return origem + " → " + destino;
        }
        if (!destino.isEmpty()) {
            return destino;
        }
        if (!origem.isEmpty()) {
            return origem;
        }
        return "";
    }

    public static String passengersLabel(Pacote p) {
        if (p == null) {
            return "";
        }
        int total = p.getNumAdultos() + p.getNumCriancas();
        if (total <= 0) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        sb.append(p.getNumAdultos()).append(p.getNumAdultos() == 1 ? " adulto" : " adultos");
        if (p.getNumCriancas() > 0) {
            sb.append(", ").append(p.getNumCriancas()).append(p.getNumCriancas() == 1 ? " criança" : " crianças");
        }
        return sb.toString();
    }

    public static String datesFromViagens(List<Viagens> viagens) {
        if (viagens == null || viagens.isEmpty()) {
            return "";
        }
        Timestamp start = null;
        Timestamp end = null;
        for (Viagens v : viagens) {
            if (v == null) {
                continue;
            }
            if (v.getDataHoraPartida() != null && (start == null || v.getDataHoraPartida().before(start))) {
                start = v.getDataHoraPartida();
            }
            if (v.getDataHoraRegresso() != null && (end == null || v.getDataHoraRegresso().after(end))) {
                end = v.getDataHoraRegresso();
            }
        }
        if (start == null && end == null) {
            return "";
        }
        if (start != null && end != null) {
            return DATE_FMT.format(start.toLocalDateTime()) + " – " + DATE_FMT.format(end.toLocalDateTime());
        }
        if (start != null) {
            return DATE_FMT.format(start.toLocalDateTime());
        }
        return DATE_FMT.format(end.toLocalDateTime());
    }

    public static String tipoLabel(Pacote p) {
        if (p == null || p.getTipo() == null) {
            return "Pacote";
        }
        String t = p.getTipo().trim();
        if ("Oferta".equalsIgnoreCase(t)) {
            return "Oferta";
        }
        if ("Pacote".equalsIgnoreCase(t)) {
            return "Pacote";
        }
        return t;
    }
}
