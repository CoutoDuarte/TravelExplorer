<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.util.ArrayList,Connection.Classes.Pacote,Connection.CRUD.PacoteCRUD" %>
<%!
String destJspParamSafe(String value) {
    if (value == null) {
        return "";
    }
    return value.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
}
%>
<%
boolean destAuth = Boolean.TRUE.equals(session.getAttribute("auth"));
String destUserType = session.getAttribute("userType") != null ? String.valueOf(session.getAttribute("userType")) : "";
boolean destCliente = destAuth && "cliente".equals(destUserType);
boolean destStaff = destAuth && "staff".equals(destUserType);
String destCtx = request.getContextPath();

List<Pacote> ofertasDestaque = new ArrayList<>();
List<Pacote> todosPacotes = new ArrayList<>();

java.text.DecimalFormatSymbols symD = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
symD.setDecimalSeparator(',');
symD.setGroupingSeparator(' ');
java.text.DecimalFormat dfDest = new java.text.DecimalFormat("#,##0.00", symD);

try {
    ofertasDestaque = new PacoteCRUD().findRecent(3);
    todosPacotes = new PacoteCRUD().findAll();
} catch (Exception ignored) {
}
%>
<div class="public-page public-page--destinations">
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <div class="public-page-hero">
                <div class="public-page-hero__main">
                    <span class="public-page-header__eyebrow">Destinos</span>
                    <h1 class="public-page-header__title">Explora ofertas e pacotes disponíveis</h1>
                    <p class="public-page-header__lead">Consulta propostas criadas pela equipa TravelExplorer e encontra a viagem certa para ti.</p>
                    <div class="public-page-hero__actions">
                        <% if (destCliente) { %>
                        <a class="btn btn-primary" href="<%= destCtx %>/index.jsp?page=customer-dashboard">Área de cliente</a>
                        <% } else if (destStaff) { %>
                        <a class="btn btn-primary" href="<%= destCtx %>/index.jsp?page=staff-dashboard">Área staff</a>
                        <% } else { %>
                        <a class="btn btn-primary" href="<%= destCtx %>/index.jsp?page=register">Criar conta</a>
                        <% } %>
                    </div>
                </div>
                <aside class="public-info-card">
                    <span class="public-info-card__eyebrow">Como funciona</span>
                    <h2 class="public-info-card__title">Ofertas e pacotes na mesma página</h2>
                    <ul class="public-info-card__list">
                        <li><strong>Ofertas em destaque</strong> — as propostas mais recentes.</li>
                        <li><strong>Pacotes disponíveis</strong> — catálogo completo da equipa.</li>
                        <li><strong>Plano personalizado</strong> — usa o assistente na página inicial.</li>
                    </ul>
                </aside>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--accent public-section--balanced">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Ofertas" />
                <jsp:param name="heading" value="Ofertas em destaque" />
                <jsp:param name="description" value="As três propostas mais recentes da equipa." />
            </jsp:include>

            <% if (ofertasDestaque.isEmpty()) { %>
            <p class="text-muted">Ainda não existem ofertas ou pacotes disponíveis.</p>
            <% } else { %>
            <div class="cards-grid public-cards-grid">
                <% for (Pacote op : ofertasDestaque) {
                    int imgN = (op.getIdPacote() % 4) + 1;
                    String imgPath = "/assets/img/offers/offer-" + imgN + ".jpg";
                    String titulo = op.getNome() != null ? op.getNome() : "Pacote";
                    String desc = op.getDescricao() != null ? op.getDescricao() : "";
                    if (desc.length() > 160) desc = desc.substring(0, 160) + "…";
                    String precoTxt = "Desde " + dfDest.format(op.getPrecoBase()) + " €";
                    String tag2 = op.getNumAdultos() + " adultos";
                    if (op.getNumCriancas() > 0) tag2 = tag2 + ", " + op.getNumCriancas() + " crianças";
                    String extraRef = "Ref. " + op.getIdPacote();
                    String altTxt = destJspParamSafe(titulo);
                    String titleTxt = destJspParamSafe(titulo);
                    String descTxt = destJspParamSafe(desc);
                    String tag2Txt = destJspParamSafe(tag2);
                    String extraTxt = destJspParamSafe(extraRef);
                    String precoParam = destJspParamSafe(precoTxt);
                    String gradientSeed = String.valueOf((op.getIdPacote() % 3) + 1);
                    String idPacoteTxt = String.valueOf(op.getIdPacote());
                %>
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="image" value="<%= imgPath %>" />
                    <jsp:param name="alt" value="<%= altTxt %>" />
                    <jsp:param name="tag1" value="Oferta" />
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

    <section class="public-page__section public-page__section--soft public-section--balanced">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Pacotes" />
                <jsp:param name="heading" value="Pacotes disponíveis" />
                <jsp:param name="description" value="Todas as propostas registadas na base de dados." />
            </jsp:include>

            <% if (todosPacotes.isEmpty()) { %>
            <p class="text-muted">Ainda não existem ofertas ou pacotes disponíveis.</p>
            <% } else { %>
            <div class="cards-grid public-cards-grid">
                <% for (Pacote op : todosPacotes) {
                    int imgN = (op.getIdPacote() % 4) + 1;
                    String imgPath = "/assets/img/offers/offer-" + imgN + ".jpg";
                    String titulo = op.getNome() != null ? op.getNome() : "Pacote";
                    String desc = op.getDescricao() != null ? op.getDescricao() : "";
                    if (desc.length() > 160) desc = desc.substring(0, 160) + "…";
                    String precoTxt = "Desde " + dfDest.format(op.getPrecoBase()) + " €";
                    String tag2 = op.getNumAdultos() + " adultos";
                    if (op.getNumCriancas() > 0) tag2 = tag2 + ", " + op.getNumCriancas() + " crianças";
                    String extraRef = "Ref. " + op.getIdPacote();
                    String altTxt = destJspParamSafe(titulo);
                    String titleTxt = destJspParamSafe(titulo);
                    String descTxt = destJspParamSafe(desc);
                    String tag2Txt = destJspParamSafe(tag2);
                    String extraTxt = destJspParamSafe(extraRef);
                    String precoParam = destJspParamSafe(precoTxt);
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

    <section class="public-page__section public-page__section--accent">
        <div class="container">
            <jsp:include page="/components/public/public_cta_banner.jsp">
                <jsp:param name="title" value="Pronto para planear a tua viagem?" />
                <jsp:param name="text" value="Usa o assistente de pesquisa na página inicial para comparar voos, alojamentos e criar o teu plano personalizado." />
                <jsp:param name="href" value="/index.jsp?page=home#hero-studio" />
                <jsp:param name="buttonText" value="Começar a planear" />
            </jsp:include>
        </div>
    </section>
</div>
