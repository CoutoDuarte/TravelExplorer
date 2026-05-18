<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.util.ArrayList,Connection.Classes.Promocao,Connection.Classes.Pacote,Connection.CRUD.PromocaoCRUD,Connection.CRUD.PacoteCRUD" %>
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

java.time.format.DateTimeFormatter promoDateFmt = java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy", java.util.Locale.forLanguageTag("pt-PT"));
%>
<div class="public-page">
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
                        <a class="btn btn-primary" href="<%= homeCtx %>/index.jsp?page=destinations">Ver destinos</a>
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
                    String titulo = promo.getTitulo() != null ? promo.getTitulo() : "Promoção";
                    String destino = promo.getDestino() != null ? promo.getDestino() : "";
                    String condicao = promo.getCondicao() != null ? promo.getCondicao() : "";
                    String periodo = "";
                    if (promo.getPeriodoInicio() != null && promo.getPeriodoFim() != null) {
                        periodo = promo.getPeriodoInicio().format(promoDateFmt) + " – " + promo.getPeriodoFim().format(promoDateFmt);
                    } else if (promo.getPeriodoInicio() != null) {
                        periodo = "Desde " + promo.getPeriodoInicio().format(promoDateFmt);
                    }
                    String desc = condicao;
                    if (!periodo.isEmpty()) {
                        desc = periodo + (condicao.isEmpty() ? "" : " · " + condicao);
                    }
                    if (desc.length() > 160) desc = desc.substring(0, 160) + "…";
                    int seed = (promo.getIdPromocao() % 6) + 1;
                    String titleParam = jspParamSafe(titulo);
                    String textParam = jspParamSafe(desc.isEmpty() ? destino : desc);
                    String destParam = jspParamSafe(destino.isEmpty() ? "—" : destino);
                    String cardTextParam = textParam.isEmpty() ? destParam : textParam;
                    String gradientSeedParam = String.valueOf(seed);
                %>
                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="gradientSeed" value="<%= gradientSeedParam %>" />
                    <jsp:param name="title" value="<%= titleParam %>" />
                    <jsp:param name="text" value="<%= cardTextParam %>" />
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
                    String img = op.getImagemUrl() != null ? op.getImagemUrl().trim() : "";
                    String titulo = op.getNome() != null ? op.getNome() : "Oferta";
                    String desc = op.getDescricao() != null ? op.getDescricao() : "";
                    if (desc.length() > 120) desc = desc.substring(0, 120) + "…";
                    String preco = "Desde " + dfHome.format(op.getPrecoBase()) + " €";
                    String tag2Txt = op.getNumAdultos() + " adultos";
                    if (op.getNumCriancas() > 0) {
                        tag2Txt = tag2Txt + ", " + op.getNumCriancas() + " crianças";
                    }
                    String extraTxt = "Ref. " + op.getIdPacote();
                    String showSaveParam = homeCliente ? "true" : (homeLoggedIn ? "" : "guest");
                    String imagemUrlParam = jspParamSafe(img);
                    String altParam = jspParamSafe(titulo);
                    String tag2Param = jspParamSafe(tag2Txt);
                    String titleParam = jspParamSafe(titulo);
                    String extraParam = jspParamSafe(extraTxt);
                    String descParam = jspParamSafe(desc);
                    String priceParam = jspParamSafe(preco);
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
                    <jsp:param name="showSave" value="<%= showSaveParam %>" />
                    <jsp:param name="redirectPage" value="home" />
                </jsp:include>
                <% } %>
            </div>
            <div class="actions-row" style="margin-top: 1rem;">
                <a class="btn btn-secondary" href="<%= homeCtx %>/index.jsp?page=destinations">Ver todos os destinos</a>
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
