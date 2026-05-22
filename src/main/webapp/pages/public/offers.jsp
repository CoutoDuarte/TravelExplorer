<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,Connection.Classes.Pacote,Connection.Classes.Promocao,Connection.Classes.Viagens,Connection.CRUD.PacoteCRUD,Connection.CRUD.PromocaoCRUD,Connection.CRUD.ViagemCRUD" %>
<%!
String jspParamSafe(String value) {
    if (value == null) {
        return "";
    }
    return value.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
}
%>
<%
PacoteCRUD pacoteCRUDPublic = new PacoteCRUD();
ViagemCRUD viagemCRUDOffers = new ViagemCRUD();
PromocaoCRUD promocaoCRUDOffers = new PromocaoCRUD();
List<Pacote> listaOfertas = pacoteCRUDPublic.findPublicOfertas(50);
java.text.DecimalFormatSymbols symO = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
symO.setDecimalSeparator(',');
symO.setGroupingSeparator(' ');
java.text.DecimalFormat dfOferta = new java.text.DecimalFormat("#,##0.00", symO);
String offersCtx = request.getContextPath();
%>

<div class="public-page public-page--offers">
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <header class="public-page-header">
                <span class="public-page-header__eyebrow">Ofertas</span>
                <h1 class="public-page-header__title">Explorar ofertas</h1>
                <p class="public-page-header__lead">Descobre as propostas criadas pela equipa TravelExplorer.</p>
            </header>

            <% if (listaOfertas == null || listaOfertas.isEmpty()) { %>
            <div class="empty-state offers-page__empty">
                <p>Ainda não existem ofertas disponíveis.</p>
                <a class="btn btn-primary" href="<%= offersCtx %>/index.jsp#hero-studio" style="margin-top: 1rem;">Planear viagem</a>
            </div>
            <% } else { %>
            <div class="cards-grid public-cards-grid offers-page__grid">
                <% for (Pacote op : listaOfertas) {
                    if (!Connection.PacotePublicHelper.isPubliclyVisible(op)) continue;
                    List<Viagens> vList = viagemCRUDOffers.findByPacote(op.getIdPacote());
                    String titulo = op.getNome() != null ? op.getNome() : "Oferta";
                    String routeLine = Connection.PacotePublicHelper.routeFromViagens(vList);
                    String datesLine = Connection.PacotePublicHelper.datesFromViagens(vList);
                    String metaLine = Connection.PacotePublicHelper.passengersLabel(op);
                    Promocao promo = promocaoCRUDOffers.findActiveByPacote(op.getIdPacote());
                    Connection.PacotePublicHelper.PromoPrice pp = Connection.PacotePublicHelper.priceForPacote(op, promo);
                    String precoTxt = Connection.PacotePublicHelper.formatPrecoCard(pp, dfOferta);
                    String precoOrigTxt = Connection.PacotePublicHelper.formatPrecoOriginalRiscado(pp, dfOferta);
                    String badgeTxt = Connection.PacotePublicHelper.promoBadge(pp);
                    String imgSrc = Connection.PacotePublicHelper.resolveImageSrc(op, offersCtx);
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
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="imagemUrl" value="<%= safeImagem %>" />
                    <jsp:param name="gradientOnly" value="<%= gradientOnly %>" />
                    <jsp:param name="alt" value="<%= safeTitulo %>" />
                    <jsp:param name="tag1" value="Oferta" />
                    <jsp:param name="title" value="<%= safeTitulo %>" />
                    <jsp:param name="routeLine" value="<%= safeRoute %>" />
                    <jsp:param name="metaLine" value="<%= safeMeta %>" />
                    <jsp:param name="datesLine" value="<%= safeDates %>" />
                    <jsp:param name="price" value="<%= safePreco %>" />
                    <jsp:param name="priceOriginal" value="<%= safePrecoOrig %>" />
                    <jsp:param name="promoBadge" value="<%= safeBadge %>" />
                    <jsp:param name="idPacote" value="<%= safeIdPacote %>" />
                    <jsp:param name="gradientSeed" value="<%= safeSeed %>" />
                </jsp:include>
                <% } %>
            </div>
            <% } %>
        </div>
    </section>
</div>
