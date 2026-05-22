<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Connection.Classes.ClienteOfertaGuardada" %>
<%@ page import="Connection.Classes.Pacote" %>
<%@ page import="Connection.Classes.Promocao" %>
<%@ page import="Connection.Classes.Viagens" %>
<%@ page import="Connection.CRUD.ClienteOfertaGuardadaCRUD" %>
<%@ page import="Connection.CRUD.PacoteCRUD" %>
<%@ page import="Connection.CRUD.PromocaoCRUD" %>
<%@ page import="Connection.CRUD.ViagemCRUD" %>
<%!
private String escapeHtml(String value) {
    if (value == null) {
        return "";
    }
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
}

private String jspParamSafe(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
}
%>
<%
Object userIdObj = session.getAttribute("userId");
Integer idCliente = null;
if (userIdObj != null) {
    try {
        idCliente = Integer.valueOf(userIdObj.toString());
    } catch (NumberFormatException ignored) {
        idCliente = null;
    }
}
if (idCliente == null) {
%>
<script>
    window.location.replace("<%= request.getContextPath() %>/index.jsp?page=login");
</script>
<%
    return;
}

String technicalError = null;
Locale ptLocale = new Locale("pt", "PT");
List<ClienteOfertaGuardada> savedOffers = new java.util.ArrayList<ClienteOfertaGuardada>();
PacoteCRUD pacoteCRUD = new PacoteCRUD();
ViagemCRUD viagemCRUD = new ViagemCRUD();
PromocaoCRUD promocaoCRUD = new PromocaoCRUD();
String savedCtx = request.getContextPath();
DecimalFormatSymbols symSaved = new DecimalFormatSymbols(ptLocale);
symSaved.setDecimalSeparator(',');
symSaved.setGroupingSeparator(' ');
DecimalFormat dfSaved = new DecimalFormat("#,##0.00", symSaved);

try {
    savedOffers = ClienteOfertaGuardadaCRUD.listarPorCliente(idCliente);
} catch (Exception e) {
    technicalError = "Erro técnico: " + e.getMessage();
}

String errorParam = request.getParameter("error");
if (technicalError == null && errorParam != null && !errorParam.trim().isEmpty()) {
    technicalError = "Erro técnico: " + errorParam;
}
%>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Guardados" />
        <jsp:param name="heading" value="Ofertas guardadas" />
        <jsp:param name="description" value="Consulta rapidamente as ofertas que guardaste para comparar ou rever mais tarde." />
    </jsp:include>

    <div class="cards-grid public-cards-grid">
        <% if (technicalError != null) { %>
            <div class="surface-block">
                <p class="text-muted"><%= escapeHtml(technicalError) %></p>
            </div>
        <% } else if (savedOffers.isEmpty()) { %>
            <div class="surface-block">
                <p class="text-muted">Ainda não tens ofertas guardadas.</p>
                <a class="btn btn-primary" href="<%= savedCtx %>/index.jsp#hero-studio" style="margin-top: 1rem;">Planear viagem</a>
            </div>
        <% } else { %>
            <% for (ClienteOfertaGuardada offer : savedOffers) {
                Pacote op = null;
                try {
                    op = pacoteCRUD.findById(offer.getIdPacote());
                } catch (Exception ignored) {}
                if (op == null || !Connection.PacotePublicHelper.isPubliclyVisible(op)) continue;
                List<Viagens> vList = viagemCRUD.findByPacote(op.getIdPacote());
                String titulo = op.getNome() != null ? op.getNome() : (offer.getNomePacote() != null ? offer.getNomePacote() : "Oferta");
                String routeLine = Connection.PacotePublicHelper.routeFromViagens(vList);
                if (routeLine.isEmpty() && offer.getOrigem() != null && offer.getDestino() != null) {
                    routeLine = offer.getOrigem().trim() + " → " + offer.getDestino().trim();
                }
                String datesLine = Connection.PacotePublicHelper.datesFromViagens(vList);
                String metaLine = Connection.PacotePublicHelper.passengersLabel(op);
                Promocao promo = promocaoCRUD.findActiveByPacote(op.getIdPacote());
                Connection.PacotePublicHelper.PromoPrice pp = Connection.PacotePublicHelper.priceForPacote(op, promo);
                String precoTxt = Connection.PacotePublicHelper.formatPrecoCard(pp, dfSaved);
                String precoOrigTxt = Connection.PacotePublicHelper.formatPrecoOriginalRiscado(pp, dfSaved);
                String badgeTxt = Connection.PacotePublicHelper.promoBadge(pp);
                String imgSrc = Connection.PacotePublicHelper.resolveImageSrc(op, savedCtx);
                String safeImagem = jspParamSafe(imgSrc != null ? imgSrc : "");
                String gradientOnly = imgSrc == null ? "true" : "false";
                String safeTitulo = jspParamSafe(titulo);
                String safeRoute = jspParamSafe(routeLine);
                String safeMeta = jspParamSafe(metaLine);
                String safeDates = jspParamSafe(datesLine);
                String safePreco = jspParamSafe(precoTxt);
                String safePrecoOrig = jspParamSafe(precoOrigTxt);
                String safeBadge = jspParamSafe(badgeTxt);
                String safeSeed = String.valueOf(Connection.PacotePublicHelper.gradientSeed(op.getIdPacote()));
                String safeIdPacote = String.valueOf(op.getIdPacote());
            %>
            <div class="saved-offer-card-wrap">
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="imagemUrl" value="<%= safeImagem %>" />
                    <jsp:param name="gradientOnly" value="<%= gradientOnly %>" />
                    <jsp:param name="alt" value="<%= safeTitulo %>" />
                    <jsp:param name="tag1" value="Guardada" />
                    <jsp:param name="title" value="<%= safeTitulo %>" />
                    <jsp:param name="routeLine" value="<%= safeRoute %>" />
                    <jsp:param name="metaLine" value="<%= safeMeta %>" />
                    <jsp:param name="datesLine" value="<%= safeDates %>" />
                    <jsp:param name="price" value="<%= safePreco %>" />
                    <jsp:param name="priceOriginal" value="<%= safePrecoOrig %>" />
                    <jsp:param name="promoBadge" value="<%= safeBadge %>" />
                    <jsp:param name="idPacote" value="<%= safeIdPacote %>" />
                    <jsp:param name="gradientSeed" value="<%= safeSeed %>" />
                    <jsp:param name="redirectPage" value="saved-offers" />
                </jsp:include>
                <form class="saved-offer-card-wrap__remove" action="<%= savedCtx %>/ClienteOfertaGuardadaServlet" method="post">
                    <input type="hidden" name="action" value="remove">
                    <input type="hidden" name="idPacote" value="<%= op.getIdPacote() %>">
                    <button class="btn btn-ghost" type="submit">Remover dos guardados</button>
                </form>
            </div>
            <% } %>
        <% } %>
    </div>
</div>
