<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.time.format.DateTimeFormatter,Connection.Classes.Reserva,Connection.Classes.Cliente,Connection.Classes.Pacote,Connection.CRUD.ReservaCRUD,Connection.CRUD.ClienteCRUD,Connection.CRUD.PacoteCRUD" %>
<%
ReservaCRUD reservaCRUD = new ReservaCRUD();
ClienteCRUD clienteCRUD = new ClienteCRUD();
PacoteCRUD pacoteCRUD = new PacoteCRUD();
List<Reserva> reservas = reservaCRUD.findAll();
DateTimeFormatter dfData = DateTimeFormatter.ofPattern("dd/MM/yyyy").withLocale(java.util.Locale.forLanguageTag("pt-PT"));
java.text.DecimalFormatSymbols sym = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
sym.setDecimalSeparator(',');
sym.setGroupingSeparator(' ');
java.text.DecimalFormat dfValor = new java.text.DecimalFormat("#,##0.00", sym);
String resBase = request.getContextPath() + "/index.jsp?page=staff-reservations";
String clientsBase = request.getContextPath() + "/index.jsp?page=staff-clients";
String commBase = request.getContextPath() + "/index.jsp?page=staff-communication";
String selRes = request.getParameter("selectedReserva");
Reserva reservaSel = null;
if (selRes != null && !selRes.trim().isEmpty()) {
    try {
        reservaSel = reservaCRUD.findById(Integer.parseInt(selRes.trim()));
    } catch (NumberFormatException ignored) {
    }
}
%>

<div id="staffResRoot" class="staff-shell staff-offers-page" data-res-base="<%= resBase %>">

<div class="flow">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Reservas" />
        <jsp:param name="heading" value="Reservas dos clientes" />
        <jsp:param name="description" value="Consulta reservas e acede rapidamente ao cliente ou à comunicação." />
    </jsp:include>

    <div class="surface-block surface-block-lg staff-action-panel">
        <% if (reservas == null || reservas.isEmpty()) { %>
        <p class="text-muted">Ainda não existem reservas registadas.</p>
        <% } else { %>
        <div class="staff-offers-table-wrap">
            <table class="staff-offers-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Data</th>
                        <th>Cliente</th>
                        <th>Pacote</th>
                        <th>Total</th>
                        <th>Estado</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Reserva r : reservas) {
                        Cliente cl = r.getIdCliente() > 0 ? clienteCRUD.findById(r.getIdCliente()) : null;
                        Pacote pk = r.getIdPacote() > 0 ? pacoteCRUD.findById(r.getIdPacote()) : null;
                        if (pk == null) {
                            pk = pacoteCRUD.findByReserva(r.getIdReserva());
                        }
                        String cliTxt = cl != null ? (cl.getNome() != null ? cl.getNome() : "") : "—";
                        String pacTxt = pk != null && pk.getNome() != null ? pk.getNome() : "—";
                        String dataTxt = r.getDataReserva() != null ? r.getDataReserva().format(dfData) : "—";
                        String commLink = commBase + "&reservaFilter=" + r.getIdReserva();
                        String clienteLink = cl != null ? clientsBase + "&selectedCliente=" + cl.getIdCliente() : clientsBase;
                    %>
                    <tr>
                        <td><%= r.getIdReserva() %></td>
                        <td><%= dataTxt %></td>
                        <td><%= cliTxt %></td>
                        <td><%= pacTxt %></td>
                        <td><%= dfValor.format(r.getTotalPagar()) %> €</td>
                        <td><%= r.getEstado() != null ? r.getEstado() : "" %></td>
                        <td class="staff-row-actions">
                            <a class="btn btn-secondary" style="padding: 0.35rem 0.65rem; font-size: 0.85rem;" href="<%= resBase %>&amp;selectedReserva=<%= r.getIdReserva() %>">Ver reserva</a>
                            <a class="btn btn-secondary" style="padding: 0.35rem 0.65rem; font-size: 0.85rem;" href="<%= clienteLink %>">Ver cliente</a>
                            <a class="btn btn-secondary" style="padding: 0.35rem 0.65rem; font-size: 0.85rem;" href="<%= commLink %>">Comunicação</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>

</div>

<% if (reservaSel != null) {
    Cliente clSel = reservaSel.getIdCliente() > 0 ? clienteCRUD.findById(reservaSel.getIdCliente()) : null;
    Pacote pkSel = reservaSel.getIdPacote() > 0 ? pacoteCRUD.findById(reservaSel.getIdPacote()) : pacoteCRUD.findByReserva(reservaSel.getIdReserva());
    String titulo = reservaSel.getTitulo() != null && !reservaSel.getTitulo().isEmpty()
        ? reservaSel.getTitulo() : (pkSel != null && pkSel.getNome() != null ? pkSel.getNome() : "Reserva");
%>
<div id="staffResBackdrop" class="staff-drawer-backdrop is-open" aria-hidden="false"></div>
<div id="staffResDrawer" class="staff-drawer is-open" aria-hidden="false">
    <div class="staff-drawer__header">
        <h2 class="staff-drawer__title">Reserva #<%= reservaSel.getIdReserva() %></h2>
        <button type="button" class="staff-drawer__close" id="staffResClose" aria-label="Fechar">&times;</button>
    </div>
    <div class="staff-drawer__body flow">
        <p><strong>Título:</strong> <%= titulo %></p>
        <p><strong>Rota:</strong> <%= reservaSel.getOrigem() != null ? reservaSel.getOrigem() : "—" %> → <%= reservaSel.getDestino() != null ? reservaSel.getDestino() : "—" %></p>
        <p><strong>Total:</strong> <%= dfValor.format(reservaSel.getTotalPagar()) %> €</p>
        <p><strong>Estado:</strong> <%= reservaSel.getEstado() != null ? reservaSel.getEstado() : "—" %></p>
        <% if (clSel != null) { %>
        <p><strong>Cliente:</strong> <%= clSel.getNome() %> (<%= clSel.getEmail() != null ? clSel.getEmail() : "" %>)</p>
        <% } %>
        <div class="actions-row">
            <% if (clSel != null) { %>
            <a class="btn btn-secondary" href="<%= clientsBase %>&amp;selectedCliente=<%= clSel.getIdCliente() %>">Ver cliente</a>
            <% } %>
            <a class="btn btn-secondary" href="<%= commBase %>&amp;reservaFilter=<%= reservaSel.getIdReserva() %>">Comunicação</a>
        </div>
    </div>
</div>
<script>
(function() {
  var base = document.getElementById('staffResRoot').getAttribute('data-res-base') || '';
  function closeAll() { window.location.href = base; }
  document.getElementById('staffResBackdrop')?.addEventListener('click', function(ev) { if (ev.target.id === 'staffResBackdrop') closeAll(); });
  document.getElementById('staffResClose')?.addEventListener('click', closeAll);
  document.addEventListener('keydown', function(ev) { if (ev.key === 'Escape') closeAll(); });
})();
</script>
<% } %>
