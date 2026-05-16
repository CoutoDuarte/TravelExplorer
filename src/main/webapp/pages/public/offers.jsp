<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,Connection.Classes.Pacote,Connection.CRUD.PacoteCRUD" %>
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
List<Pacote> listaOfertas = pacoteCRUDPublic.findAll();
java.text.DecimalFormatSymbols symO = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
symO.setDecimalSeparator(',');
symO.setGroupingSeparator(' ');
java.text.DecimalFormat dfOferta = new java.text.DecimalFormat("#,##0.00", symO);
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
            </div>
            <% } else { %>
            <div class="cards-grid public-cards-grid offers-page__grid">
                <% for (Pacote op : listaOfertas) {
                    int imgN = (op.getIdPacote() % 4) + 1;
                    String imgPath = "/assets/img/offers/offer-" + imgN + ".jpg";
                    String titulo = op.getNome() != null ? op.getNome() : "Pacote";
                    String desc = op.getDescricao() != null ? op.getDescricao() : "";
                    if (desc.length() > 160) {
                        desc = desc.substring(0, 160) + "…";
                    }
                    String precoTxt = "Desde " + dfOferta.format(op.getPrecoBase()) + " €";
                    String tag2 = op.getNumAdultos() + " adultos";
                    if (op.getNumCriancas() > 0) {
                        tag2 = tag2 + ", " + op.getNumCriancas() + " crianças";
                    }
                    String extraRef = "Ref. " + op.getIdPacote();
                    String altTxt = jspParamSafe(titulo);
                    String titleTxt = jspParamSafe(titulo);
                    String descTxt = jspParamSafe(desc);
                    String tag2Txt = jspParamSafe(tag2);
                    String extraTxt = jspParamSafe(extraRef);
                    String precoParam = jspParamSafe(precoTxt);
                    String gradientSeed = String.valueOf((op.getIdPacote() % 3) + 1);
                    String idPacoteTxt = String.valueOf(op.getIdPacote());
                %>
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="image" value="<%= imgPath %>" />
                    <jsp:param name="alt" value="<%= altTxt %>" />
                    <jsp:param name="tag1" value="Pacote" />
                    <jsp:param name="tag2" value="<%= tag2Txt %>" />
                    <jsp:param name="title" value="<%= titleTxt %>" />
                    <jsp:param name="origin" value="—" />
                    <jsp:param name="destination" value="—" />
                    <jsp:param name="extra" value="<%= extraTxt %>" />
                    <jsp:param name="description" value="<%= descTxt %>" />
                    <jsp:param name="price" value="<%= precoParam %>" />
                    <jsp:param name="idPacote" value="<%= idPacoteTxt %>" />
                    <jsp:param name="gradientSeed" value="<%= gradientSeed %>" />
                </jsp:include>
                <% } %>
            </div>
            <% } %>
        </div>
    </section>
</div>
