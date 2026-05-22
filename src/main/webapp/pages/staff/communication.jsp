<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.util.ArrayList,java.time.format.DateTimeFormatter,Connection.Classes.Comunicacao,Connection.Classes.Cliente,Connection.Classes.Reserva,Connection.Classes.Pacote,Connection.CRUD.ComunicacaoCRUD,Connection.CRUD.ClienteCRUD,Connection.CRUD.ReservaCRUD,Connection.CRUD.PacoteCRUD" %>
<%
ComunicacaoCRUD comunicacaoCRUD = new ComunicacaoCRUD();
ClienteCRUD clienteCRUD = new ClienteCRUD();
ReservaCRUD reservaCRUD = new ReservaCRUD();
PacoteCRUD pacoteCRUD = new PacoteCRUD();
List<Comunicacao> pedidos = comunicacaoCRUD.findSupportTickets();
String reservaFilter = request.getParameter("reservaFilter");
String clienteFilter = request.getParameter("clienteFilter");
int filterReserva = 0;
int filterCliente = 0;
try { if (reservaFilter != null) filterReserva = Integer.parseInt(reservaFilter.trim()); } catch (NumberFormatException ignored) {}
try { if (clienteFilter != null) filterCliente = Integer.parseInt(clienteFilter.trim()); } catch (NumberFormatException ignored) {}
List<Comunicacao> visiveis = new ArrayList<>();
for (Comunicacao co : pedidos) {
    if (filterReserva > 0 && co.getIdReserva() != filterReserva) continue;
    if (filterCliente > 0 && co.getIdCliente() != filterCliente) continue;
    visiveis.add(co);
}
String selC = request.getParameter("selectedComunicacao");
Comunicacao selCom = null;
if (selC != null && !selC.trim().isEmpty()) {
    try { selCom = comunicacaoCRUD.findById(Integer.parseInt(selC.trim())); } catch (NumberFormatException ignored) {}
}
String success = request.getParameter("success");
String error = request.getParameter("error");
String commBase = request.getContextPath() + "/index.jsp?page=staff-communication";
String reservasBase = request.getContextPath() + "/index.jsp?page=staff-reservations";
String clientsBase = request.getContextPath() + "/index.jsp?page=staff-clients";
DateTimeFormatter dfPt = DateTimeFormatter.ofPattern("dd/MM/yyyy").withLocale(java.util.Locale.forLanguageTag("pt-PT"));
%>

<div id="staffCommRoot" class="staff-shell staff-offers-page" data-comm-base="<%= commBase %>">
<div class="flow">
    <% if ("support-answered".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Resposta enviada com sucesso.</div></div>
    <% } %>
    <% if ("invalid-data".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Dados inválidos.</div></div>
    <% } %>

    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Apoio" />
        <jsp:param name="heading" value="Pedidos de apoio" />
        <jsp:param name="description" value="Mensagens dos clientes com ligação direta à reserva e ficha de cliente." />
    </jsp:include>

    <% if (filterReserva > 0 || filterCliente > 0) { %>
    <p class="text-muted">
        Filtro ativo
        <% if (filterReserva > 0) { %>· reserva #<%= filterReserva %><% } %>
        <% if (filterCliente > 0) { %>· cliente #<%= filterCliente %><% } %>
        · <a href="<%= commBase %>">Limpar filtro</a>
    </p>
    <% } %>

    <div class="surface-block surface-block-lg staff-action-panel">
        <% if (visiveis.isEmpty()) { %>
        <p class="text-muted">Não existem pedidos de apoio para este filtro.</p>
        <% } else { %>
        <div class="staff-offers-table-wrap">
            <table class="staff-offers-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Título</th>
                        <th>Cliente</th>
                        <th>Reserva</th>
                        <th>Data</th>
                        <th>Estado</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Comunicacao co : visiveis) {
                        Cliente cl = co.getIdCliente() > 0 ? clienteCRUD.findById(co.getIdCliente()) : null;
                        Reserva rv = co.getIdReserva() > 0 ? reservaCRUD.findById(co.getIdReserva()) : null;
                        Pacote pk = rv != null && rv.getIdPacote() > 0 ? pacoteCRUD.findById(rv.getIdPacote()) : null;
                        if (pk == null && rv != null) pk = pacoteCRUD.findByReserva(rv.getIdReserva());
                        String clNome = cl != null && cl.getNome() != null ? cl.getNome() : "—";
                        String resTitulo = rv != null && rv.getTitulo() != null && !rv.getTitulo().isEmpty()
                            ? rv.getTitulo() : (pk != null && pk.getNome() != null ? pk.getNome() : (co.getIdReserva() > 0 ? "Reserva #" + co.getIdReserva() : "—"));
                        String d = co.getDataComunicacao() != null ? co.getDataComunicacao().format(dfPt) : "—";
                    %>
                    <tr>
                        <td><%= co.getIdComunicacao() %></td>
                        <td><strong><%= co.getTitulo() != null ? co.getTitulo() : "" %></strong></td>
                        <td><%= clNome %></td>
                        <td><%= resTitulo %></td>
                        <td><%= d %></td>
                        <td><%= co.getEstado() != null ? co.getEstado() : "" %></td>
                        <td class="staff-row-actions">
                            <a class="btn btn-secondary" style="padding:0.35rem 0.65rem;font-size:0.85rem;" href="<%= commBase %>&amp;selectedComunicacao=<%= co.getIdComunicacao() %><% if (filterReserva > 0) { %>&amp;reservaFilter=<%= filterReserva %><% } %><% if (filterCliente > 0) { %>&amp;clienteFilter=<%= filterCliente %><% } %>">Responder</a>
                            <% if (co.getIdReserva() > 0) { %>
                            <a class="btn btn-secondary" style="padding:0.35rem 0.65rem;font-size:0.85rem;" href="<%= reservasBase %>&amp;selectedReserva=<%= co.getIdReserva() %>">Ver reserva</a>
                            <% } %>
                            <% if (cl != null) { %>
                            <a class="btn btn-secondary" style="padding:0.35rem 0.65rem;font-size:0.85rem;" href="<%= clientsBase %>&amp;selectedCliente=<%= cl.getIdCliente() %>">Ver cliente</a>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>

<% if (selCom != null) {
    Cliente clSel = selCom.getIdCliente() > 0 ? clienteCRUD.findById(selCom.getIdCliente()) : null;
    Reserva rvSel = selCom.getIdReserva() > 0 ? reservaCRUD.findById(selCom.getIdReserva()) : null;
%>
<div id="staffCommBackdrop" class="staff-drawer-backdrop is-open" aria-hidden="false"></div>
<div id="staffCommDrawer" class="staff-drawer is-open" aria-hidden="false">
    <div class="staff-drawer__header">
        <h2 class="staff-drawer__title">Pedido #<%= selCom.getIdComunicacao() %></h2>
        <button type="button" class="staff-drawer__close" id="staffCommClose" aria-label="Fechar">&times;</button>
    </div>
    <div class="staff-drawer__body flow">
        <p><strong>Cliente:</strong> <%= clSel != null ? clSel.getNome() : "—" %> <% if (clSel != null && clSel.getEmail() != null) { %>(<%= clSel.getEmail() %>)<% } %></p>
        <% if (selCom.getIdReserva() > 0) { %>
        <p><strong>Reserva:</strong> #<%= selCom.getIdReserva() %><% if (rvSel != null && rvSel.getTitulo() != null) { %> — <%= rvSel.getTitulo() %><% } %></p>
        <% } %>
        <div class="actions-row">
            <% if (selCom.getIdReserva() > 0) { %>
            <a class="btn btn-secondary" href="<%= reservasBase %>&amp;selectedReserva=<%= selCom.getIdReserva() %>">Ver reserva</a>
            <% } %>
            <% if (clSel != null) { %>
            <a class="btn btn-secondary" href="<%= clientsBase %>&amp;selectedCliente=<%= clSel.getIdCliente() %>">Ver cliente</a>
            <% } %>
        </div>
        <p><strong>Mensagem:</strong></p>
        <p class="text-muted"><%= selCom.getMensagem() != null ? selCom.getMensagem() : "" %></p>
        <% if (selCom.getResposta() != null && !selCom.getResposta().trim().isEmpty()) { %>
        <div class="surface-block">
            <span class="section-title__eyebrow">Respondido</span>
            <p class="text-muted"><%= selCom.getResposta() %></p>
        </div>
        <% } else { %>
        <form class="flow" method="post" action="${pageContext.request.contextPath}/suporte">
            <input type="hidden" name="action" value="answer">
            <input type="hidden" name="idComunicacao" value="<%= selCom.getIdComunicacao() %>">
            <label for="resposta">Resposta</label>
            <textarea id="resposta" name="resposta" rows="5" required></textarea>
            <button type="submit" class="btn btn-primary">Responder</button>
        </form>
        <% } %>
    </div>
</div>
<script>
(function() {
  function closePanel(ev) {
    if (ev) {
      ev.preventDefault();
      ev.stopPropagation();
    }
    var backdrop = document.getElementById('staffCommBackdrop');
    var drawer = document.getElementById('staffCommDrawer');
    if (backdrop) {
      backdrop.classList.remove('is-open');
      backdrop.setAttribute('aria-hidden', 'true');
      backdrop.hidden = true;
    }
    if (drawer) {
      drawer.classList.remove('is-open');
      drawer.setAttribute('aria-hidden', 'true');
      drawer.hidden = true;
    }
    var url = new URL(window.location.href);
    url.searchParams.delete('selectedComunicacao');
    window.history.replaceState({}, '', url.pathname + url.search);
  }
  document.getElementById('staffCommBackdrop')?.addEventListener('click', function(ev) {
    if (ev.target.id === 'staffCommBackdrop') closePanel(ev);
  });
  document.getElementById('staffCommClose')?.addEventListener('click', closePanel);
  document.addEventListener('keydown', function(ev) {
    if (ev.key === 'Escape') closePanel();
  });
})();
</script>
<% } %>
</div>
