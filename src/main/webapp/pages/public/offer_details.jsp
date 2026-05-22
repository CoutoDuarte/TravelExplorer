<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,Connection.Classes.Pacote,Connection.Classes.Promocao,Connection.Classes.Viagens,Connection.Classes.Alojamento,Connection.Classes.Transporte,Connection.CRUD.PacoteCRUD,Connection.CRUD.PromocaoCRUD,Connection.CRUD.ViagemCRUD,Connection.CRUD.AlojamentoCRUD,Connection.CRUD.TransporteCRUD,Connection.CRUD.ClienteOfertaGuardadaCRUD" %>
<%!
String detEsc(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
}
boolean detHas(String value) {
    return value != null && !value.trim().isEmpty();
}
String detTime(java.sql.Timestamp ts) {
    if (ts == null) return "";
    String t = ts.toLocalDateTime().toLocalTime().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
    if ("00:00".equals(t)) return "";
    return t;
}
String transporteLinha(Transporte t) {
    if (t == null) return "";
    StringBuilder sb = new StringBuilder();
    if (detHas(t.getTipo())) sb.append(t.getTipo().trim());
    if (detHas(t.getEmpresa())) {
        if (sb.length() > 0) sb.append(" · ");
        sb.append(t.getEmpresa().trim());
    }
    if (detHas(t.getOrigem()) || detHas(t.getDestino())) {
        if (sb.length() > 0) sb.append(" · ");
        String orig = detHas(t.getOrigem()) ? t.getOrigem().trim() : "";
        String dest = detHas(t.getDestino()) ? t.getDestino().trim() : "";
        if (!orig.isEmpty() && !dest.isEmpty()) sb.append(orig).append(" → ").append(dest);
        else if (!dest.isEmpty()) sb.append(dest);
        else sb.append(orig);
    }
    String partida = detTime(t.getDataHoraPartida());
    String chegada = detTime(t.getDataHoraChegada());
    if (detHas(partida) || detHas(chegada)) {
        if (sb.length() > 0) sb.append(" · ");
        if (detHas(partida) && detHas(chegada)) sb.append(partida).append(" → ").append(chegada);
        else if (detHas(partida)) sb.append(partida);
        else sb.append(chegada);
    }
    if (t.getLugares() > 0) {
        if (sb.length() > 0) sb.append(" · ");
        sb.append(t.getLugares()).append(t.getLugares() == 1 ? " lugar" : " lugares");
    }
    return sb.toString();
}
%>
<%
String idPacoteStr = request.getParameter("idPacote");
if (idPacoteStr == null || idPacoteStr.trim().isEmpty()) {
    idPacoteStr = request.getParameter("id");
}
String detCtx = request.getContextPath();
boolean detAuth = Boolean.TRUE.equals(session.getAttribute("auth"));
String detUserType = session.getAttribute("userType") != null ? String.valueOf(session.getAttribute("userType")) : "";
boolean detCliente = detAuth && "cliente".equals(detUserType);
boolean detStaff = detAuth && "staff".equals(detUserType);
Integer detClienteId = null;
if (detCliente && session.getAttribute("userId") != null) {
    try { detClienteId = Integer.valueOf(session.getAttribute("userId").toString()); } catch (NumberFormatException ignored) {}
}

Pacote detPacote = null;
Promocao detPromo = null;
List<Viagens> detViagens = java.util.Collections.emptyList();
List<Alojamento> detAloj = java.util.Collections.emptyList();
List<Transporte> detTransp = java.util.Collections.emptyList();
boolean idEmFalta = idPacoteStr == null || idPacoteStr.trim().isEmpty();
boolean notPublic = false;

if (!idEmFalta) {
    try {
        detPacote = new PacoteCRUD().findById(Integer.parseInt(idPacoteStr.trim()));
        if (detPacote != null) {
            if (!Connection.PacotePublicHelper.isPubliclyVisible(detPacote)) {
                notPublic = true;
                detPacote = null;
            } else {
                int idP = detPacote.getIdPacote();
                detPromo = new PromocaoCRUD().findActiveByPacote(idP);
                detViagens = new ViagemCRUD().findByPacote(idP);
                detAloj = new AlojamentoCRUD().findByPacote(idP);
                detTransp = new TransporteCRUD().findByPacote(idP);
            }
        }
    } catch (NumberFormatException ignored) {
    }
}

java.text.DecimalFormatSymbols symD = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
symD.setDecimalSeparator(',');
symD.setGroupingSeparator(' ');
java.text.DecimalFormat dfDet = new java.text.DecimalFormat("#,##0.00", symD);

String routeLine = Connection.PacotePublicHelper.routeFromViagens(detViagens);
String datesLine = Connection.PacotePublicHelper.datesFromViagens(detViagens);
String passengersLine = Connection.PacotePublicHelper.passengersLabel(detPacote);
String tipoTag = Connection.PacotePublicHelper.tipoLabel(detPacote);
String imgHttp = detPacote != null ? Connection.PacotePublicHelper.resolveImageSrc(detPacote, detCtx) : null;
boolean useGradient = imgHttp == null || (!imgHttp.startsWith("http://") && !imgHttp.startsWith("https://"));
int gSeed = detPacote != null ? Connection.PacotePublicHelper.gradientSeed(detPacote.getIdPacote()) : 1;
boolean isSaved = detClienteId != null && detPacote != null && ClienteOfertaGuardadaCRUD.isGuardada(detClienteId, detPacote.getIdPacote());
String saveMode = detCliente ? "true" : (detAuth ? "" : "guest");
Connection.PacotePublicHelper.PromoPrice detPreco = Connection.PacotePublicHelper.priceForPacote(detPacote, detPromo);
%>

<div class="public-page public-page--offer-details">
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <% if (idEmFalta) { %>
            <div class="surface-block surface-block-xl content-stack">
                <h1>Detalhe da oferta</h1>
                <p class="text-muted">Escolhe uma oferta na página inicial para ver o detalhe completo.</p>
                <a class="btn btn-primary" href="<%= detCtx %>/index.jsp">Ir para o início</a>
            </div>
            <% } else if (notPublic) { %>
            <div class="surface-block surface-block-xl content-stack">
                <h1>Conteúdo não disponível</h1>
                <p class="text-muted">Esta viagem é privada ou já não está disponível publicamente.</p>
                <a class="btn btn-secondary" href="<%= detCtx %>/index.jsp">Voltar ao início</a>
            </div>
            <% } else if (detPacote == null) { %>
            <div class="surface-block surface-block-xl content-stack">
                <h1>Oferta não encontrada</h1>
                <p class="text-muted">O pacote pedido não existe ou deixou de estar disponível.</p>
                <a class="btn btn-secondary" href="<%= detCtx %>/index.jsp">Voltar ao início</a>
            </div>
            <% } else {
                String nomeDet = detPacote.getNome() != null ? detPacote.getNome() : "Pacote";
                String descDet = detPacote.getDescricao() != null ? detPacote.getDescricao() : "";
            %>
            <div class="split-layout split-layout--content-start offer-details-layout">
                <div class="offer-details-layout__media">
                    <div class="card__media offer-details-media<% if (useGradient) { %> card__media--gradient card__media--gradient-<%= gSeed %><% } %>">
                        <% if (!useGradient && imgHttp != null) { %>
                        <img src="<%= detEsc(imgHttp) %>" alt="<%= detEsc(nomeDet) %>" loading="lazy" decoding="async" referrerpolicy="no-referrer" onerror="this.remove(); this.parentElement.classList.add('card__media--gradient', 'card__media--gradient-<%= gSeed %>', 'card__media--gradient-fallback');">
                        <% } %>
                    </div>
                </div>

                <div class="surface-block surface-block-xl content-stack">
                    <span class="section-title__eyebrow">Detalhe</span>
                    <div class="actions-row">
                        <span class="card__tag"><%= detEsc(tipoTag) %></span>
                        <% if (detPreco.hasPromo) { %>
                        <span class="card__tag card__tag--promo"><%= detEsc(Connection.PacotePublicHelper.promoBadge(detPreco)) %></span>
                        <% } %>
                        <% if (detHas(passengersLine)) { %>
                        <span class="card__tag"><%= detEsc(passengersLine) %></span>
                        <% } %>
                    </div>
                    <h1><%= detEsc(nomeDet) %></h1>
                    <% if (detHas(routeLine)) { %>
                    <p class="offer-card__route"><strong>Rota:</strong> <%= detEsc(routeLine) %></p>
                    <% } %>
                    <% if (detHas(datesLine)) { %>
                    <p class="offer-card__dates"><strong>Datas:</strong> <%= detEsc(datesLine) %></p>
                    <% } %>

                    <% if (detPreco.hasPromo && detPromo != null) { %>
                    <div class="surface-block offer-details-promo">
                        <h2 style="font-size: 1.1rem; margin: 0 0 0.5rem;">Promoção ativa</h2>
                        <% if (detHas(detPromo.getTitulo())) { %><p><strong><%= detEsc(detPromo.getTitulo()) %></strong></p><% } %>
                        <% if (detHas(detPromo.getCondicao())) { %><p class="text-muted"><%= detEsc(detPromo.getCondicao()) %></p><% } %>
                    </div>
                    <% } %>

                    <div class="offer-details-price-block">
                        <% if (detPreco.hasPromo) { %>
                        <span class="card__price card__price--original"><%= dfDet.format(detPreco.originalPrice) %> €</span>
                        <span class="card__price card__price--promo" style="font-size: 1.75rem;">Desde <%= dfDet.format(detPreco.discountedPrice) %> €</span>
                        <% } else { %>
                        <span class="card__price" style="font-size: 1.75rem;">Desde <%= dfDet.format(detPreco.originalPrice) %> €</span>
                        <% } %>
                    </div>

                    <% if (detHas(descDet)) { %>
                    <div class="content-stack">
                        <h2 style="font-size: 1.2rem;">Descrição</h2>
                        <p style="white-space: pre-wrap;"><%= detEsc(descDet) %></p>
                    </div>
                    <% } %>

                    <% if (!detViagens.isEmpty()) { %>
                    <div class="content-stack">
                        <h2 style="font-size: 1.2rem;">Voos</h2>
                        <% for (Viagens v : detViagens) {
                            String vRoute = "";
                            if (detHas(v.getOrigem()) && detHas(v.getDestino())) {
                                vRoute = v.getOrigem().trim() + " → " + v.getDestino().trim();
                            } else if (detHas(v.getDestino())) {
                                vRoute = v.getDestino().trim();
                            } else if (detHas(v.getOrigem())) {
                                vRoute = v.getOrigem().trim();
                            }
                            String vDep = detTime(v.getDataHoraPartida());
                            String vArr = detTime(v.getDataHoraRegresso());
                            String vTimes = "";
                            if (detHas(vDep) && detHas(vArr)) vTimes = vDep + " → " + vArr;
                            else if (detHas(vDep)) vTimes = vDep;
                            else if (detHas(vArr)) vTimes = vArr;
                            else vTimes = "Horário não disponível";
                        %>
                        <div class="surface-block" style="padding: 0.85rem 1rem;">
                            <% if (detHas(v.getEmpresa())) { %><p><strong><%= detEsc(v.getEmpresa()) %></strong></p><% } %>
                            <% if (detHas(vRoute)) { %><p><%= detEsc(vRoute) %></p><% } %>
                            <p class="text-muted"><%= detEsc(vTimes) %></p>
                            <% if (v.getPreco() > 0) { %><p><%= dfDet.format(v.getPreco()) %> €</p><% } %>
                        </div>
                        <% } %>
                    </div>
                    <% } %>

                    <% if (!detAloj.isEmpty()) { %>
                    <div class="content-stack">
                        <h2 style="font-size: 1.2rem;">Alojamento</h2>
                        <% for (Alojamento a : detAloj) { %>
                        <div class="surface-block" style="padding: 0.85rem 1rem;">
                            <p><strong><%= detEsc(a.getNome() != null ? a.getNome() : "Alojamento") %></strong></p>
                            <% if (detHas(a.getMorada())) { %><p class="text-muted"><%= detEsc(a.getMorada()) %></p><% } %>
                            <% if (a.getPreco() > 0) { %><p><%= dfDet.format(a.getPreco()) %> €</p><% } %>
                        </div>
                        <% } %>
                    </div>
                    <% } %>

                    <% if (!detTransp.isEmpty()) { %>
                    <div class="content-stack">
                        <h2 style="font-size: 1.2rem;">Transporte</h2>
                        <% for (Transporte t : detTransp) {
                            String tLinha = transporteLinha(t);
                        %>
                        <div class="surface-block" style="padding: 0.85rem 1rem;">
                            <% if (detHas(tLinha)) { %><p class="text-muted"><%= detEsc(tLinha) %></p><% } %>
                            <% if (t.getPreco() > 0) { %><p><%= dfDet.format(t.getPreco()) %> €</p><% } %>
                        </div>
                        <% } %>
                    </div>
                    <% } %>

                    <div class="actions-row">
                        <a class="btn btn-secondary" href="<%= detCtx %>/index.jsp">Voltar ao início</a>
                        <% if (!detStaff) { %>
                            <% if ("true".equals(saveMode)) { %>
                                <% if (isSaved) { %>
                                <span class="btn btn-ghost" style="pointer-events:none;">Guardada</span>
                                <% } else { %>
                                <form action="<%= detCtx %>/ClienteOfertaGuardadaServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="save">
                                    <input type="hidden" name="idPacote" value="<%= detPacote.getIdPacote() %>">
                                    <input type="hidden" name="redirect" value="offer-details&idPacote=<%= detPacote.getIdPacote() %>">
                                    <button type="submit" class="btn btn-primary">Guardar oferta</button>
                                </form>
                                <% } %>
                            <% } else if ("guest".equals(saveMode)) { %>
                            <a class="btn btn-primary" href="<%= detCtx %>/index.jsp?page=login&amp;redirect=<%= java.net.URLEncoder.encode("offer-details&idPacote=" + detPacote.getIdPacote(), "UTF-8") %>">Entrar para guardar</a>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </section>
</div>
