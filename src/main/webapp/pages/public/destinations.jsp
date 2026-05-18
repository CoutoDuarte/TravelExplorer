<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.util.ArrayList,Connection.Classes.Pacote,Connection.CRUD.PacoteCRUD,Connection.CRUD.ClienteOfertaGuardadaCRUD" %>
<%!
String destJspParamSafe(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
}
String resolveImage(Pacote op) {
    if (op.getImagemUrl() != null && !op.getImagemUrl().trim().isEmpty()) {
        return op.getImagemUrl().trim();
    }
    return "";
}
%>
<%
boolean destAuth = Boolean.TRUE.equals(session.getAttribute("auth"));
String destUserType = session.getAttribute("userType") != null ? String.valueOf(session.getAttribute("userType")) : "";
boolean destCliente = destAuth && "cliente".equals(destUserType);
boolean destStaff = destAuth && "staff".equals(destUserType);
Integer destClienteId = null;
if (destCliente && session.getAttribute("userId") != null) {
    try { destClienteId = Integer.valueOf(session.getAttribute("userId").toString()); } catch (NumberFormatException ignored) {}
}
String destCtx = request.getContextPath();
String saveMode = destCliente ? "true" : (destAuth ? "" : "guest");

List<Pacote> ofertasDestaque = new ArrayList<>();
List<Pacote> todosPacotes = new ArrayList<>();

java.text.DecimalFormatSymbols symD = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
symD.setDecimalSeparator(',');
symD.setGroupingSeparator(' ');
java.text.DecimalFormat dfDest = new java.text.DecimalFormat("#,##0.00", symD);
PacoteCRUD pacoteCRUD = new PacoteCRUD();

try {
    ofertasDestaque = pacoteCRUD.findPublicOfertas(12);
    todosPacotes = pacoteCRUD.findPublicPacotes(50);
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
                        <li><strong>Ofertas</strong> — campanhas e propostas em destaque.</li>
                        <li><strong>Pacotes</strong> — viagens completas da equipa.</li>
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
                <jsp:param name="description" value="Propostas públicas criadas pela equipa (tipo Oferta)." />
            </jsp:include>

            <% if (ofertasDestaque.isEmpty()) { %>
            <p class="text-muted">Ainda não existem ofertas públicas disponíveis.</p>
            <% } else { %>
            <div class="cards-grid public-cards-grid">
                <% for (Pacote op : ofertasDestaque) {
                    String imgPath = resolveImage(op);
                    String titulo = op.getNome() != null ? op.getNome() : "Oferta";
                    String desc = op.getDescricao() != null ? op.getDescricao() : "";
                    if (desc.length() > 160) desc = desc.substring(0, 160) + "…";
                    String precoTxt = "Desde " + dfDest.format(op.getPrecoBase()) + " €";
                    String tag2 = op.getNumAdultos() + " adultos";
                    if (op.getNumCriancas() > 0) tag2 = tag2 + ", " + op.getNumCriancas() + " crianças";
                    boolean isSaved = destClienteId != null && ClienteOfertaGuardadaCRUD.isGuardada(destClienteId, op.getIdPacote());
                    String extraRef = "Ref. " + op.getIdPacote();
                    String isSavedParam = isSaved ? "true" : "false";
                    String imagemUrlParam = destJspParamSafe(imgPath);
                    String altParam = destJspParamSafe(titulo);
                    String tag2Param = destJspParamSafe(tag2);
                    String titleParam = destJspParamSafe(titulo);
                    String extraParam = destJspParamSafe(extraRef);
                    String descParam = destJspParamSafe(desc);
                    String priceParam = destJspParamSafe(precoTxt);
                    String idPacoteParam = String.valueOf(op.getIdPacote());
                    String gradientSeedParam = String.valueOf((op.getIdPacote() % 3) + 1);
                %>
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="imagemUrl" value="<%= imagemUrlParam %>" />
                    <jsp:param name="alt" value="<%= altParam %>" />
                    <jsp:param name="tag1" value="Oferta" />
                    <jsp:param name="tag2" value="<%= tag2Param %>" />
                    <jsp:param name="title" value="<%= titleParam %>" />
                    <jsp:param name="origin" value="—" />
                    <jsp:param name="destination" value="—" />
                    <jsp:param name="extra" value="<%= extraParam %>" />
                    <jsp:param name="description" value="<%= descParam %>" />
                    <jsp:param name="price" value="<%= priceParam %>" />
                    <jsp:param name="idPacote" value="<%= idPacoteParam %>" />
                    <jsp:param name="gradientSeed" value="<%= gradientSeedParam %>" />
                    <jsp:param name="showSave" value="<%= saveMode %>" />
                    <jsp:param name="isSaved" value="<%= isSavedParam %>" />
                    <jsp:param name="redirectPage" value="destinations" />
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
                <jsp:param name="description" value="Pacotes públicos criados pela equipa (tipo Pacote)." />
            </jsp:include>

            <% if (todosPacotes.isEmpty()) { %>
            <p class="text-muted">Ainda não existem pacotes públicos disponíveis.</p>
            <% } else { %>
            <div class="cards-grid public-cards-grid">
                <% for (Pacote op : todosPacotes) {
                    String imgPath = resolveImage(op);
                    String titulo = op.getNome() != null ? op.getNome() : "Pacote";
                    String desc = op.getDescricao() != null ? op.getDescricao() : "";
                    if (desc.length() > 160) desc = desc.substring(0, 160) + "…";
                    String precoTxt = "Desde " + dfDest.format(op.getPrecoBase()) + " €";
                    String tag2 = op.getNumAdultos() + " adultos";
                    if (op.getNumCriancas() > 0) tag2 = tag2 + ", " + op.getNumCriancas() + " crianças";
                    boolean isSaved = destClienteId != null && ClienteOfertaGuardadaCRUD.isGuardada(destClienteId, op.getIdPacote());
                    String extraRefPkg = "Ref. " + op.getIdPacote();
                    String isSavedParamPkg = isSaved ? "true" : "false";
                    String imagemUrlParamPkg = destJspParamSafe(imgPath);
                    String altParamPkg = destJspParamSafe(titulo);
                    String tag2ParamPkg = destJspParamSafe(tag2);
                    String titleParamPkg = destJspParamSafe(titulo);
                    String extraParamPkg = destJspParamSafe(extraRefPkg);
                    String descParamPkg = destJspParamSafe(desc);
                    String priceParamPkg = destJspParamSafe(precoTxt);
                    String idPacoteParamPkg = String.valueOf(op.getIdPacote());
                    String gradientSeedParamPkg = String.valueOf((op.getIdPacote() % 3) + 1);
                %>
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="imagemUrl" value="<%= imagemUrlParamPkg %>" />
                    <jsp:param name="alt" value="<%= altParamPkg %>" />
                    <jsp:param name="tag1" value="Pacote" />
                    <jsp:param name="tag2" value="<%= tag2ParamPkg %>" />
                    <jsp:param name="title" value="<%= titleParamPkg %>" />
                    <jsp:param name="origin" value="—" />
                    <jsp:param name="destination" value="—" />
                    <jsp:param name="extra" value="<%= extraParamPkg %>" />
                    <jsp:param name="description" value="<%= descParamPkg %>" />
                    <jsp:param name="price" value="<%= priceParamPkg %>" />
                    <jsp:param name="idPacote" value="<%= idPacoteParamPkg %>" />
                    <jsp:param name="gradientSeed" value="<%= gradientSeedParamPkg %>" />
                    <jsp:param name="showSave" value="<%= saveMode %>" />
                    <jsp:param name="isSaved" value="<%= isSavedParamPkg %>" />
                    <jsp:param name="redirectPage" value="destinations" />
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
