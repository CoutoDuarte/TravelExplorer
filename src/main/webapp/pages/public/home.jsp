<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.util.ArrayList,java.util.Map,Connection.Classes.Promocao,Connection.Classes.Pacote,Connection.Classes.Viagens,Connection.CRUD.PromocaoCRUD,Connection.CRUD.PacoteCRUD,Connection.CRUD.ViagemCRUD" %>
<%!
String jspParamSafe(String value) {
    if (value == null) {
        return "";
    }
    return value.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
}
%>
<%
boolean homeAuth = Boolean.TRUE.equals(session.getAttribute("auth"));
String homeUserType = session.getAttribute("userType") != null ? String.valueOf(session.getAttribute("userType")) : "";
boolean homeCliente = homeAuth && "cliente".equals(homeUserType);
boolean homeStaff = homeAuth && "staff".equals(homeUserType);
boolean homeLoggedIn = homeCliente || homeStaff;
String homeCtx = request.getContextPath();

List<Promocao> promocoesAtivas = new ArrayList<>();
List<Pacote> ofertasHome = new ArrayList<>();
try {
    promocoesAtivas = new PromocaoCRUD().findActive();
    ofertasHome = new PacoteCRUD().findPublicOfertas(3);
} catch (Exception ignored) {
}
java.text.DecimalFormatSymbols symH = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
symH.setDecimalSeparator(',');
symH.setGroupingSeparator(' ');
java.text.DecimalFormat dfHome = new java.text.DecimalFormat("#,##0.00", symH);
ViagemCRUD viagemCRUDHome = new ViagemCRUD();
Map<Integer, Promocao> promoPorPacote = Connection.PacotePublicHelper.mapActivePromosByPacote(promocoesAtivas);
PacoteCRUD pacoteCRUDHome = new PacoteCRUD();

java.time.format.DateTimeFormatter promoDateFmt = java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy", java.util.Locale.forLanguageTag("pt-PT"));
%>
<div class="public-page">
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
    <section class="public-page__section public-page__section--hero hero-studio" id="hero-studio">
        <div class="container hero-studio__container">
            <div class="hero-studio__top">
                <div class="hero-studio__copy">
                    <span class="public-hero__eyebrow">Explora o mundo com confiança</span>
                    <h1 class="public-hero__title hero-studio__title hero-studio__title--wide">
                        Encontra a tua próxima viagem com o TravelExplorer
                    </h1>
                    <p class="public-hero__text hero-studio__text">
                        Descobre destinos, compara voos e escolhe o alojamento ideal numa experiência
                        pensada para viajar com calma e estilo.
                    </p>
                    <div class="public-hero__actions">
                        <a class="btn btn-primary" href="<%= homeCtx %>/index.jsp#hero-studio">Planear viagem</a>
                        <% if (homeCliente) { %>
                        <a class="btn btn-secondary" href="<%= homeCtx %>/index.jsp?page=customer-dashboard">Área de cliente</a>
                        <% } else if (homeStaff) { %>
                        <a class="btn btn-secondary" href="<%= homeCtx %>/index.jsp?page=staff-dashboard">Área staff</a>
                        <% } else { %>
                        <a class="btn btn-secondary" href="<%= homeCtx %>/index.jsp?page=register">Criar conta</a>
                        <% } %>
                    </div>
                    <div class="public-hero__highlights hero-studio__highlights">
                        <span class="public-hero__highlight">Pesquisa inteligente</span>
                        <span class="public-hero__highlight">Planos personalizados</span>
                        <span class="public-hero__highlight">Reservas na tua conta</span>
                    </div>
                </div>
            </div>
            <%@ include file="/components/public/public_hero_search.jspf" %>
        </div>
    </section>

    <section class="public-page__section public-page__section--soft home-ideas public-section--balanced">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Promoções" />
                <jsp:param name="heading" value="Promoções" />
                <jsp:param name="description" value="Campanhas e condições especiais da equipa TravelExplorer." />
                <jsp:param name="extraClass" value="section-title--home-ideas" />
            </jsp:include>

            <% if (promocoesAtivas.isEmpty()) { %>
            <div class="empty-state public-empty-state">
                <p>Não existem promoções ativas neste momento.</p>
            </div>
            <% } else { %>
            <div class="cards-grid public-cards-grid home-promos__grid">
                <% for (Promocao promo : promocoesAtivas) {
                    if (promo.getIdPacote() <= 0) continue;
                    Pacote opPromo = pacoteCRUDHome.findById(promo.getIdPacote());
                    if (opPromo == null || !Connection.PacotePublicHelper.isPubliclyVisible(opPromo)) continue;
                    List<Viagens> vListPromo = viagemCRUDHome.findByPacote(opPromo.getIdPacote());
                    String tituloPromo = opPromo.getNome() != null ? opPromo.getNome() : (promo.getTitulo() != null ? promo.getTitulo() : "Oferta");
                    String routeLinePromo = Connection.PacotePublicHelper.routeFromViagens(vListPromo);
                    String datesLinePromo = Connection.PacotePublicHelper.datesFromViagens(vListPromo);
                    String metaLinePromo = Connection.PacotePublicHelper.passengersLabel(opPromo);
                    Connection.PacotePublicHelper.PromoPrice ppPromo = Connection.PacotePublicHelper.priceForPacote(opPromo, promo);
                    String precoPromo = Connection.PacotePublicHelper.formatPrecoCard(ppPromo, dfHome);
                    String precoOrigPromo = Connection.PacotePublicHelper.formatPrecoOriginalRiscado(ppPromo, dfHome);
                    String badgePromo = Connection.PacotePublicHelper.promoBadge(ppPromo);
                    String imgSrcPromo = Connection.PacotePublicHelper.resolveImageSrc(opPromo, homeCtx);
                    String safeImagemPromo = jspParamSafe(imgSrcPromo != null ? imgSrcPromo : "");
                    String gradientOnlyPromo = imgSrcPromo == null ? "true" : "false";
                    String safeTituloPromo = jspParamSafe(tituloPromo);
                    String safeRoutePromo = jspParamSafe(routeLinePromo);
                    String safeMetaPromo = jspParamSafe(metaLinePromo);
                    String safeDatesPromo = jspParamSafe(datesLinePromo);
                    String safePrecoPromo = jspParamSafe(precoPromo);
                    String safePrecoOrigPromo = jspParamSafe(precoOrigPromo);
                    String safeBadgePromo = jspParamSafe(badgePromo);
                    String safeSeedPromo = String.valueOf(Connection.PacotePublicHelper.gradientSeed(opPromo.getIdPacote()));
                    String safeIdPromo = String.valueOf(opPromo.getIdPacote());
                %>
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="imagemUrl" value="<%= safeImagemPromo %>" />
                    <jsp:param name="gradientOnly" value="<%= gradientOnlyPromo %>" />
                    <jsp:param name="alt" value="<%= safeTituloPromo %>" />
                    <jsp:param name="tag1" value="Promoção" />
                    <jsp:param name="title" value="<%= safeTituloPromo %>" />
                    <jsp:param name="routeLine" value="<%= safeRoutePromo %>" />
                    <jsp:param name="metaLine" value="<%= safeMetaPromo %>" />
                    <jsp:param name="datesLine" value="<%= safeDatesPromo %>" />
                    <jsp:param name="price" value="<%= safePrecoPromo %>" />
                    <jsp:param name="priceOriginal" value="<%= safePrecoOrigPromo %>" />
                    <jsp:param name="promoBadge" value="<%= safeBadgePromo %>" />
                    <jsp:param name="idPacote" value="<%= safeIdPromo %>" />
                    <jsp:param name="gradientSeed" value="<%= safeSeedPromo %>" />
                    <jsp:param name="redirectPage" value="home" />
                </jsp:include>
                <% } %>
            </div>
            <% } %>
        </div>
    </section>

    <section class="public-page__section public-page__section--accent public-section--balanced">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Ofertas" />
                <jsp:param name="heading" value="Ofertas em destaque" />
                <jsp:param name="description" value="Seleção de ofertas públicas da equipa TravelExplorer." />
                <jsp:param name="extraClass" value="section-title--home-ideas" />
            </jsp:include>
            <% if (ofertasHome.isEmpty()) { %>
            <p class="text-muted">Não existem ofertas em destaque neste momento.</p>
            <% } else { %>
            <div class="cards-grid public-cards-grid">
                <% for (Pacote op : ofertasHome) {
                    if (!Connection.PacotePublicHelper.isPubliclyVisible(op)) continue;
                    List<Viagens> vList = viagemCRUDHome.findByPacote(op.getIdPacote());
                    String titulo = op.getNome() != null ? op.getNome() : "Oferta";
                    String routeLine = Connection.PacotePublicHelper.routeFromViagens(vList);
                    String datesLine = Connection.PacotePublicHelper.datesFromViagens(vList);
                    String metaLine = Connection.PacotePublicHelper.passengersLabel(op);
                    Promocao promoOferta = promoPorPacote.get(op.getIdPacote());
                    Connection.PacotePublicHelper.PromoPrice ppOferta = Connection.PacotePublicHelper.priceForPacote(op, promoOferta);
                    String preco = Connection.PacotePublicHelper.formatPrecoCard(ppOferta, dfHome);
                    String precoOrig = Connection.PacotePublicHelper.formatPrecoOriginalRiscado(ppOferta, dfHome);
                    String badge = Connection.PacotePublicHelper.promoBadge(ppOferta);
                    String showSaveParam = homeCliente ? "true" : (homeLoggedIn ? "" : "guest");
                    String imgSrc = Connection.PacotePublicHelper.resolveImageSrc(op, homeCtx);
                    String safeImagem = jspParamSafe(imgSrc != null ? imgSrc : "");
                    String gradientOnly = imgSrc == null ? "true" : "false";
                    String safeTitulo = jspParamSafe(titulo);
                    String safeRoute = jspParamSafe(routeLine);
                    String safeMeta = jspParamSafe(metaLine);
                    String safeDates = jspParamSafe(datesLine);
                    String safePreco = jspParamSafe(preco);
                    String safePrecoOrig = jspParamSafe(precoOrig);
                    String safeBadge = jspParamSafe(badge);
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
                    <jsp:param name="showSave" value="<%= showSaveParam %>" />
                    <jsp:param name="redirectPage" value="home" />
                </jsp:include>
                <% } %>
            </div>
            <% } %>
        </div>
    </section>

    <% if (!homeLoggedIn) { %>
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/public/public_cta_banner.jsp">
                <jsp:param name="title" value="Guarda as tuas ofertas favoritas e acompanha as tuas reservas" />
                <jsp:param name="text" value="Cria a tua conta para aceder à área pessoal, guardar ofertas e acompanhar o estado das reservas." />
                <jsp:param name="href" value="/index.jsp?page=register" />
                <jsp:param name="buttonText" value="Começar agora" />
            </jsp:include>
        </div>
    </section>
    <% } %>
</div>
