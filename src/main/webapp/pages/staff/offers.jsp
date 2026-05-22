<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,Connection.Classes.Pacote,Connection.Classes.Reserva,Connection.Classes.Cliente,Connection.CRUD.PacoteCRUD,Connection.CRUD.ReservaCRUD,Connection.CRUD.ClienteCRUD" %>
<%
PacoteCRUD pacoteCRUD = new PacoteCRUD();
ReservaCRUD reservaCRUD = new ReservaCRUD();
ClienteCRUD clienteCRUD = new ClienteCRUD();
List<Pacote> ofertasPublicas = pacoteCRUD.findPublicOfertas(100);
List<Pacote> reservasGeradas = pacoteCRUD.findByTipo("Reserva");
String activeTab = request.getParameter("tab");
if (activeTab == null || activeTab.isEmpty()) {
    activeTab = "ofertas";
}
String success = request.getParameter("success");
String error = request.getParameter("error");
String offersBase = request.getContextPath() + "/index.jsp?page=staff-offers";
String wizardUrl = request.getContextPath() + "/index.jsp?page=staff-offer-wizard";
String reservasStaffUrl = request.getContextPath() + "/index.jsp?page=staff-reservations";
java.text.DecimalFormatSymbols sym = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
sym.setDecimalSeparator(',');
sym.setGroupingSeparator(' ');
java.text.DecimalFormat dfPreco = new java.text.DecimalFormat("#,##0.00", sym);
%>

<div id="staffOffersRoot" class="staff-shell staff-offers-page" data-offers-base="<%= offersBase %>">

<div class="flow">

    <% if ("offer-created".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Oferta pública criada com sucesso.</div></div>
    <% } %>
    <% if ("invalid-data".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Dados inválidos.</div></div>
    <% } %>

    <div class="staff-offers-page-header">
        <div class="section-title">
            <span class="section-title__eyebrow">Ofertas</span>
            <h1 class="section-title__heading">Gestão de ofertas</h1>
            <p class="section-title__description">Cria e gere ofertas públicas apresentadas aos clientes. As reservas geradas pelos clientes aparecem em separado, apenas para consulta.</p>
        </div>
    </div>

    <div class="staff-tabs" role="tablist">
        <a class="staff-tabs__item<%= "ofertas".equals(activeTab) ? " is-active" : "" %>" href="<%= offersBase %>&amp;tab=ofertas">Ofertas públicas</a>
        <a class="staff-tabs__item<%= "reservas".equals(activeTab) ? " is-active" : "" %>" href="<%= offersBase %>&amp;tab=reservas">Reservas geradas</a>
    </div>

    <% if ("ofertas".equals(activeTab)) { %>
    <div class="actions-row" style="margin-bottom: 1rem;">
        <a class="btn btn-primary" href="<%= wizardUrl %>">+ Nova oferta</a>
    </div>

    <% if (ofertasPublicas == null || ofertasPublicas.isEmpty()) { %>
    <div class="surface-block surface-block-lg staff-offers-empty">
        <p class="text-muted">Ainda não existem ofertas públicas. Cria a primeira com o assistente de viagem.</p>
        <a class="btn btn-primary" href="<%= wizardUrl %>">+ Nova oferta</a>
    </div>
    <% } else { %>
    <div class="staff-offer-cards">
        <% for (Pacote p : ofertasPublicas) {
            if (!Connection.PacotePublicHelper.isPubliclyVisible(p)) continue;
            String imgHttp = Connection.PacotePublicHelper.resolveImageSrc(p, request.getContextPath());
            int gSeed = Connection.PacotePublicHelper.gradientSeed(p.getIdPacote());
            boolean useGrad = imgHttp == null || (!imgHttp.startsWith("http://") && !imgHttp.startsWith("https://"));
        %>
        <article class="staff-offer-card">
            <div class="staff-offer-card__media<% if (useGrad) { %> card__media--gradient card__media--gradient-<%= gSeed %><% } %>">
                <% if (!useGrad && imgHttp != null) { %>
                <img src="<%= imgHttp %>" alt="" loading="lazy" decoding="async" referrerpolicy="no-referrer" onerror="this.remove(); this.parentElement.classList.add('card__media--gradient', 'card__media--gradient-<%= gSeed %>', 'card__media--gradient-fallback');">
                <% } %>
            </div>
            <div class="staff-offer-card__body">
                <h3><%= p.getNome() != null ? p.getNome() : "Oferta" %></h3>
                <p><strong><%= dfPreco.format(p.getPrecoBase()) %> €</strong> · <%= p.getNumAdultos() %> adulto<%= p.getNumAdultos() != 1 ? "s" : "" %><% if (p.getNumCriancas() > 0) { %>, <%= p.getNumCriancas() %> criança<%= p.getNumCriancas() != 1 ? "s" : "" %><% } %></p>
                <div class="actions-row">
                    <a class="btn btn-secondary" style="font-size:0.85rem;padding:0.35rem 0.65rem;" href="<%= request.getContextPath() %>/index.jsp?page=offer-details&amp;idPacote=<%= p.getIdPacote() %>">Ver detalhes</a>
                </div>
            </div>
        </article>
        <% } %>
    </div>
    <% } %>

    <% } else { %>
    <div class="surface-block surface-block-lg staff-action-panel">
        <% if (reservasGeradas == null || reservasGeradas.isEmpty()) { %>
        <p class="text-muted">Ainda não existem pacotes gerados a partir de reservas de clientes.</p>
        <% } else { %>
        <div class="staff-offers-table-wrap">
            <table class="staff-offers-table">
                <thead>
                    <tr>
                        <th>Reserva</th>
                        <th>Cliente</th>
                        <th>Título</th>
                        <th>Total</th>
                        <th>Estado</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Pacote p : reservasGeradas) {
                        Reserva r = p.getIdReserva() > 0 ? reservaCRUD.findById(p.getIdReserva()) : null;
                        Cliente cl = r != null && r.getIdCliente() > 0 ? clienteCRUD.findById(r.getIdCliente()) : null;
                        String titulo = r != null && r.getTitulo() != null && !r.getTitulo().isEmpty()
                            ? r.getTitulo() : (p.getNome() != null ? p.getNome() : "—");
                        String rota = "—";
                        if (r != null) {
                            rota = (r.getOrigem() != null ? r.getOrigem() : "—") + " → " + (r.getDestino() != null ? r.getDestino() : "—");
                        }
                        String cliNome = cl != null && cl.getNome() != null ? cl.getNome() : "—";
                        String estado = r != null && r.getEstado() != null ? r.getEstado() : "—";
                        int idRes = r != null ? r.getIdReserva() : p.getIdReserva();
                    %>
                    <tr>
                        <td>#<%= idRes > 0 ? idRes : "—" %></td>
                        <td><%= cliNome %></td>
                        <td><strong><%= titulo %></strong><br><span class="text-muted" style="font-size:0.85rem;"><%= rota %></span></td>
                        <td><%= dfPreco.format(p.getPrecoBase()) %> €</td>
                        <td><%= estado %></td>
                        <td>
                            <% if (idRes > 0) { %>
                            <a class="btn btn-secondary" style="padding:0.35rem 0.65rem;font-size:0.85rem;" href="<%= reservasStaffUrl %>&amp;selectedReserva=<%= idRes %>">Ver reserva</a>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
    <% } %>

</div>
</div>
