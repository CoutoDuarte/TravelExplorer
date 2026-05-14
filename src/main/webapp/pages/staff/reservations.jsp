<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.time.format.DateTimeFormatter,Connection.Classes.Reserva,Connection.Classes.Cliente,Connection.Classes.Pacote,Connection.CRUD.ReservaCRUD,Connection.CRUD.ClienteCRUD,Connection.CRUD.PacoteCRUD" %>
<%
ReservaCRUD reservaCRUD = new ReservaCRUD();
ClienteCRUD clienteCRUD = new ClienteCRUD();
PacoteCRUD pacoteCRUD = new PacoteCRUD();
List<Reserva> reservas = reservaCRUD.findAll();
DateTimeFormatter dfData = DateTimeFormatter.ofPattern("dd/MM/yyyy").withLocale(java.util.Locale.forLanguageTag("pt-PT"));
java.text.DecimalFormatSymbols sym = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
sym.setDecimalSeparator(',');
java.text.DecimalFormat dfValor = new java.text.DecimalFormat("#,##0.00", sym);
String selRes = request.getParameter("selectedReserva");
Reserva reservaSel = null;
if (selRes != null && !selRes.trim().isEmpty()) {
    try {
        reservaSel = reservaCRUD.findById(Integer.parseInt(selRes.trim()));
    } catch (NumberFormatException ignored) {
    }
}
Cliente cliRes = null;
Pacote pacRes = null;
if (reservaSel != null) {
    if (reservaSel.getIdCliente() > 0) {
        cliRes = clienteCRUD.findById(reservaSel.getIdCliente());
    }
    if (reservaSel.getIdPacote() > 0) {
        pacRes = pacoteCRUD.findById(reservaSel.getIdPacote());
    } else {
        pacRes = pacoteCRUD.findByReserva(reservaSel.getIdReserva());
    }
}
String resBase = request.getContextPath() + "/index.jsp?page=staff-reservations";
%>

<div id="staffResRoot" class="staff-shell staff-offers-page" data-res-base="<%= resBase %>">

<div class="flow">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Reservas" />
        <jsp:param name="heading" value="Gestão de reservas" />
        <jsp:param name="description" value="Lista de reservas registadas na base de dados." />
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
                        <th>Total</th>
                        <th>Estado</th>
                        <th>Cliente</th>
                        <th>Pacote</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Reserva r : reservas) {
                        Cliente cl = r.getIdCliente() > 0 ? clienteCRUD.findById(r.getIdCliente()) : null;
                        Pacote pk = r.getIdPacote() > 0 ? pacoteCRUD.findById(r.getIdPacote()) : null;
                        if (pk == null && r.getIdPacote() <= 0) {
                            pk = pacoteCRUD.findByReserva(r.getIdReserva());
                        }
                        String cliTxt = cl != null ? (cl.getNome() != null ? cl.getNome() : "") + (cl.getEmail() != null ? " · " + cl.getEmail() : "") : "—";
                        String pacTxt = pk != null && pk.getNome() != null ? pk.getNome() : "—";
                        String dataTxt = r.getDataReserva() != null ? r.getDataReserva().format(dfData) : "—";
                    %>
                    <tr>
                        <td><%= r.getIdReserva() %></td>
                        <td><%= dataTxt %></td>
                        <td><%= dfValor.format(r.getTotalPagar()) %> €</td>
                        <td><%= r.getEstado() != null ? r.getEstado() : "" %></td>
                        <td><%= cliTxt %></td>
                        <td><%= pacTxt %></td>
                        <td><a class="btn btn-secondary" style="padding: 0.35rem 0.65rem; font-size: 0.85rem;" href="<%= resBase %>&amp;selectedReserva=<%= r.getIdReserva() %>">Ver detalhes</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>

<% if (reservaSel != null) { %>
<div id="staffResBackdrop" class="staff-drawer-backdrop is-open" aria-hidden="false"></div>
<div id="staffResDrawer" class="staff-drawer is-open" aria-hidden="false">
    <div class="staff-drawer__header">
        <h2 class="staff-drawer__title">Reserva #<%= reservaSel.getIdReserva() %></h2>
        <button type="button" class="staff-drawer__close" id="staffResClose" aria-label="Fechar">&times;</button>
    </div>
    <div class="staff-drawer__body flow">
        <p><strong>Data da reserva:</strong> <%= reservaSel.getDataReserva() != null ? reservaSel.getDataReserva().format(dfData) : "—" %></p>
        <p><strong>Total a pagar:</strong> <%= dfValor.format(reservaSel.getTotalPagar()) %> €</p>
        <p><strong>Estado:</strong> <%= reservaSel.getEstado() != null ? reservaSel.getEstado() : "" %></p>
        <p><strong>Cliente:</strong> <% if (cliRes != null) { %><%= cliRes.getNome() != null ? cliRes.getNome() : "" %> — <%= cliRes.getEmail() != null ? cliRes.getEmail() : "" %><% } else { %>—<% } %></p>
        <p><strong>Pacote:</strong> <% if (pacRes != null) { %><%= pacRes.getNome() != null ? pacRes.getNome() : "" %> (#<%= pacRes.getIdPacote() %>)<% } else { %>—<% } %></p>
    </div>
</div>
<% } %>

</div>

<% if (reservaSel != null) { %>
<script>
(function() {
  var base = document.getElementById('staffResRoot').getAttribute('data-res-base') || '';
  var backdrop = document.getElementById('staffResBackdrop');
  var btn = document.getElementById('staffResClose');
  function closeAll() { window.location.href = base; }
  if (backdrop) backdrop.addEventListener('click', function(ev) { if (ev.target === backdrop) closeAll(); });
  if (btn) btn.addEventListener('click', function(ev) { ev.preventDefault(); closeAll(); });
  document.addEventListener('keydown', function(ev) { if (ev.key === 'Escape') closeAll(); });
})();
</script>
<% } %>
