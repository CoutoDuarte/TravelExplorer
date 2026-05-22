<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.util.ArrayList,Connection.Classes.Pacote,Connection.Classes.Promocao,Connection.Classes.Viagens,Connection.CRUD.PacoteCRUD,Connection.CRUD.PromocaoCRUD,Connection.CRUD.ViagemCRUD,Connection.CRUD.ClienteOfertaGuardadaCRUD" %>
<%!
String destJspParamSafe(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
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
List<Promocao> promocoesAtivas = new ArrayList<>();

java.text.DecimalFormatSymbols symD = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
symD.setDecimalSeparator(',');
symD.setGroupingSeparator(' ');
java.text.DecimalFormat dfDest = new java.text.DecimalFormat("#,##0.00", symD);
java.time.format.DateTimeFormatter promoDateFmt = java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy", java.util.Locale.forLanguageTag("pt-PT"));
PacoteCRUD pacoteCRUD = new PacoteCRUD();
ViagemCRUD viagemCRUD = new ViagemCRUD();

try {
    ofertasDestaque = pacoteCRUD.findPublicOfertas(12);
    todosPacotes = pacoteCRUD.findPublicPacotes(50);
    promocoesAtivas = new PromocaoCRUD().findActive();
} catch (Exception ignored) {
}
%>
<div class="public-page public-page--destinations">
    <% if ("offerSaved".equals(request.getParameter("offerSaved"))) { %>
    <div class="container" style="padding-top: 1rem;">
        <div class="public-search-alert public-search-alert--success" role="status">Oferta guardada com sucesso.</div>
    </div>
    <% } %>
    <% if ("offerSaveError".equals(request.getParameter("offerSaveError"))) { %>
    <div class="container" style="padding-top: 1rem;">
        <div class="public-search-alert" role="alert">Não foi possível guardar a oferta. Tenta novamente.</div>
    </div>
    <% } %>
    <% if ("offerRemoved".equals(request.getParameter("offerRemoved"))) { %>
    <div class="container" style="padding-top: 1rem;">
        <div class="public-search-alert public-search-alert--success" role="status">Oferta removida dos favoritos.</div>
    </div>
    <% } %>
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <div class="public-page-hero">
                <div class="public-page-hero__main">
                    <span class="public-page-header__eyebrow">Destinos</span>
                    <h1 class="public-page-header__title">Explora ofertas e pacotes disponíveis</h1>
                    <p class="public-page-header__lead">Consulta propostas criadas pela equipa TravelExplorer e encontra a viagem certa para ti.</p>
                    <div class="public-page-hero__actions">
                        <a class="btn btn-primary" href="<%= destCtx %>/index.jsp#hero-studio">Criar nova viagem</a>
                        <% if (destCliente) { %>
                        <a class="btn btn-secondary" href="<%= destCtx %>/index.jsp?page=customer-dashboard">Área de cliente</a>
                        <% } else if (destStaff) { %>
                        <a class="btn btn-secondary" href="<%= destCtx %>/index.jsp?page=staff-dashboard">Área staff</a>
                        <% } else { %>
                        <a class="btn btn-secondary" href="<%= destCtx %>/index.jsp?page=register">Criar conta</a>
                        <% } %>
                    </div>
                </div>
                <aside class="public-info-card">
                    <span class="public-info-card__eyebrow">Como funciona</span>
                    <h2 class="public-info-card__title">Ofertas, pacotes e promoções</h2>
                    <ul class="public-info-card__list">
                        <li><strong>Ofertas</strong> — campanhas e propostas em destaque.</li>
                        <li><strong>Pacotes</strong> — viagens completas da equipa.</li>
                        <li><strong>Nova viagem</strong> — usa o assistente na página inicial.</li>
                    </ul>
                </aside>
            </div>
        </div>
    </section>

    <% if (!promocoesAtivas.isEmpty()) { %>
    <section class="public-page__section public-page__section--soft public-section--balanced">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Promoções" />
                <jsp:param name="heading" value="Promoções ativas" />
                <jsp:param name="description" value="Descontos e campanhas válidas neste período." />
            </jsp:include>
            <div class="cards-grid public-cards-grid">
                <% for (Promocao promo : promocoesAtivas) {
                    String promoTitulo = promo.getTitulo() != null ? promo.getTitulo() : "Promoção";
                    String promoDest = promo.getDestino() != null ? promo.getDestino() : "";
                    String promoCond = promo.getCondicao() != null ? promo.getCondicao() : "";
                    if (promoCond.length() > 140) promoCond = promoCond.substring(0, 140) + "…";
                    String periodo = "";
                    if (promo.getPeriodoInicio() != null && promo.getPeriodoFim() != null) {
                        periodo = promo.getPeriodoInicio().format(promoDateFmt) + " – " + promo.getPeriodoFim().format(promoDateFmt);
                    }
                    int seed = (promo.getIdPromocao() % 3) + 1;
                    String detailLink = promo.getIdPacote() > 0
                        ? "offer-details&idPacote=" + promo.getIdPacote()
                        : "destinations";
                %>
                <article class="card public-offer-card">
                    <div class="card__media card__media--gradient card__media--gradient-<%= seed %>"></div>
                    <div class="card__body">
                        <div class="card__meta">
                            <span class="card__tag">Promoção</span>
                            <% if (!promoDest.isEmpty()) { %>
                            <span class="card__tag"><%= destJspParamSafe(promoDest) %></span>
                            <% } %>
                        </div>
                        <h3 class="card__title"><%= destJspParamSafe(promoTitulo) %></h3>
                        <% if (!periodo.isEmpty()) { %>
                        <p class="offer-card__dates"><%= destJspParamSafe(periodo) %></p>
                        <% } %>
                        <% if (!promoCond.isEmpty()) { %>
                        <p class="offer-card__description"><%= destJspParamSafe(promoCond) %></p>
                        <% } %>
                        <div class="card__footer">
                            <span class="card__price">Promoção ativa</span>
                            <div class="actions-row">
                                <a class="btn btn-secondary" href="<%= destCtx %>/index.jsp?page=<%= detailLink %>">Ver detalhes</a>
                            </div>
                        </div>
                    </div>
                </article>
                <% } %>
            </div>
        </div>
    </section>
    <% } %>

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
                    if (!Connection.PacotePublicHelper.isPubliclyVisible(op)) continue;
                    List<Viagens> vList = viagemCRUD.findByPacote(op.getIdPacote());
                    String titulo = op.getNome() != null ? op.getNome() : "Oferta";
                    String routeLine = Connection.PacotePublicHelper.routeFromViagens(vList);
                    String datesLine = Connection.PacotePublicHelper.datesFromViagens(vList);
                    String metaLine = Connection.PacotePublicHelper.passengersLabel(op);
                    String precoTxt = "Desde " + dfDest.format(op.getPrecoBase()) + " €";
                    boolean isSaved = destClienteId != null && ClienteOfertaGuardadaCRUD.isGuardada(destClienteId, op.getIdPacote());
                    String isSavedParam = isSaved ? "true" : "false";
                    String imgSrc = Connection.PacotePublicHelper.resolveImageSrc(op, destCtx);
                    String imagemUrlParam = destJspParamSafe(imgSrc != null ? imgSrc : "");
                    String gradientOnly = imgSrc == null ? "true" : "false";
                %>
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="imagemUrl" value="<%= imagemUrlParam %>" />
                    <jsp:param name="gradientOnly" value="<%= gradientOnly %>" />
                    <jsp:param name="alt" value="<%= destJspParamSafe(titulo) %>" />
                    <jsp:param name="tag1" value="Oferta" />
                    <jsp:param name="title" value="<%= destJspParamSafe(titulo) %>" />
                    <jsp:param name="routeLine" value="<%= destJspParamSafe(routeLine) %>" />
                    <jsp:param name="metaLine" value="<%= destJspParamSafe(metaLine) %>" />
                    <jsp:param name="datesLine" value="<%= destJspParamSafe(datesLine) %>" />
                    <jsp:param name="price" value="<%= destJspParamSafe(precoTxt) %>" />
                    <jsp:param name="idPacote" value="<%= String.valueOf(op.getIdPacote()) %>" />
                    <jsp:param name="gradientSeed" value="<%= String.valueOf(Connection.PacotePublicHelper.gradientSeed(op.getIdPacote())) %>" />
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
                    if (!Connection.PacotePublicHelper.isPubliclyVisible(op)) continue;
                    List<Viagens> vList = viagemCRUD.findByPacote(op.getIdPacote());
                    String titulo = op.getNome() != null ? op.getNome() : "Pacote";
                    String routeLine = Connection.PacotePublicHelper.routeFromViagens(vList);
                    String datesLine = Connection.PacotePublicHelper.datesFromViagens(vList);
                    String metaLine = Connection.PacotePublicHelper.passengersLabel(op);
                    String precoTxt = "Desde " + dfDest.format(op.getPrecoBase()) + " €";
                    boolean isSaved = destClienteId != null && ClienteOfertaGuardadaCRUD.isGuardada(destClienteId, op.getIdPacote());
                    String isSavedParamPkg = isSaved ? "true" : "false";
                    String imgSrc = Connection.PacotePublicHelper.resolveImageSrc(op, destCtx);
                    String imagemUrlParam = destJspParamSafe(imgSrc != null ? imgSrc : "");
                    String gradientOnly = imgSrc == null ? "true" : "false";
                %>
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="imagemUrl" value="<%= imagemUrlParam %>" />
                    <jsp:param name="gradientOnly" value="<%= gradientOnly %>" />
                    <jsp:param name="alt" value="<%= destJspParamSafe(titulo) %>" />
                    <jsp:param name="tag1" value="Pacote" />
                    <jsp:param name="title" value="<%= destJspParamSafe(titulo) %>" />
                    <jsp:param name="routeLine" value="<%= destJspParamSafe(routeLine) %>" />
                    <jsp:param name="metaLine" value="<%= destJspParamSafe(metaLine) %>" />
                    <jsp:param name="datesLine" value="<%= destJspParamSafe(datesLine) %>" />
                    <jsp:param name="price" value="<%= destJspParamSafe(precoTxt) %>" />
                    <jsp:param name="idPacote" value="<%= String.valueOf(op.getIdPacote()) %>" />
                    <jsp:param name="gradientSeed" value="<%= String.valueOf(Connection.PacotePublicHelper.gradientSeed(op.getIdPacote())) %>" />
                    <jsp:param name="showSave" value="<%= saveMode %>" />
                    <jsp:param name="isSaved" value="<%= isSavedParamPkg %>" />
                    <jsp:param name="redirectPage" value="destinations" />
                </jsp:include>
                <% } %>
            </div>
            <% } %>
        </div>
    </section>
</div>
