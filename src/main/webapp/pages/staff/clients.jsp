<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.text.NumberFormat,java.util.Locale,Connection.Classes.Cliente,Connection.Classes.Reserva,Connection.Classes.Pacote,Connection.Classes.Pagamento,Connection.CRUD.ClienteCRUD,Connection.CRUD.ReservaCRUD,Connection.CRUD.PacoteCRUD,Connection.CRUD.PagamentoCRUD" %>
<%
ClienteCRUD clienteCRUD = new ClienteCRUD();
ReservaCRUD reservaCRUD = new ReservaCRUD();
PacoteCRUD pacoteCRUD = new PacoteCRUD();
PagamentoCRUD pagamentoCRUD = new PagamentoCRUD();
List<Cliente> clientes = clienteCRUD.findAll();
NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(new Locale("pt", "PT"));
String selCli = request.getParameter("selectedCliente");
Cliente clienteSel = null;
if (selCli != null && !selCli.trim().isEmpty()) {
    try {
        clienteSel = clienteCRUD.findById(Integer.parseInt(selCli.trim()));
    } catch (NumberFormatException ignored) {
    }
}
String clientsBase = request.getContextPath() + "/index.jsp?page=staff-clients";
%>

<div id="staffClientsRoot" class="staff-shell staff-offers-page" data-clients-base="<%= clientsBase %>">

<div class="flow">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Clientes" />
        <jsp:param name="heading" value="Gestão de clientes" />
        <jsp:param name="description" value="Lista de clientes registados na base de dados com contactos e resumo de reservas." />
    </jsp:include>

    <div class="surface-block surface-block-lg staff-action-panel">
        <% if (clientes == null || clientes.isEmpty()) { %>
        <p class="text-muted">Ainda não existem clientes registados.</p>
        <% } else { %>
        <div class="staff-offers-table-wrap">
            <table class="staff-offers-table">
                <thead>
                    <tr>
                        <th>Nome</th>
                        <th>Email</th>
                        <th>Telemóvel</th>
                        <th>NIF</th>
                        <th>Última reserva</th>
                        <th>Total reservas</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Cliente c : clientes) {
                        int nRes = clienteCRUD.countReservasByCliente(c.getIdCliente());
                        String ultNome = clienteCRUD.findLatestReservaNameByCliente(c.getIdCliente());
                        String ultTxt = ultNome != null && !ultNome.isEmpty() ? ultNome : "—";
                    %>
                    <tr>
                        <td><strong><%= c.getNome() != null ? c.getNome() : "" %></strong></td>
                        <td><%= c.getEmail() != null ? c.getEmail() : "" %></td>
                        <td><%= c.getTelemovel() %></td>
                        <td><%= c.getNIF() > 0 ? String.valueOf(c.getNIF()) : "—" %></td>
                        <td><%= ultTxt %></td>
                        <td><%= nRes %></td>
                        <td><a class="btn btn-secondary" style="padding: 0.35rem 0.65rem; font-size: 0.85rem;" href="<%= clientsBase %>&amp;selectedCliente=<%= c.getIdCliente() %>">Ver ficha</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>

<% if (clienteSel != null) { %>
<div id="staffClientsBackdrop" class="staff-drawer-backdrop is-open" aria-hidden="false"></div>
<div id="staffClientsDrawer" class="staff-drawer is-open" aria-hidden="false">
    <div class="staff-drawer__header">
        <h2 class="staff-drawer__title">Cliente #<%= clienteSel.getIdCliente() %></h2>
        <button type="button" class="staff-drawer__close" id="staffClientsClose" aria-label="Fechar">&times;</button>
    </div>
    <div class="staff-drawer__body flow">
        <p><strong>Nome:</strong> <%= clienteSel.getNome() != null ? clienteSel.getNome() : "" %></p>
        <p><strong>Email:</strong> <%= clienteSel.getEmail() != null ? clienteSel.getEmail() : "" %></p>
        <p><strong>Telemóvel:</strong> <%= clienteSel.getTelemovel() %></p>
        <p><strong>NIF:</strong> <%= clienteSel.getNIF() > 0 ? String.valueOf(clienteSel.getNIF()) : "—" %></p>
        <p><strong>Morada:</strong> <%= clienteSel.getMorada() != null ? clienteSel.getMorada() : "—" %></p>
        <p><strong>Total de reservas:</strong> <%= clienteCRUD.countReservasByCliente(clienteSel.getIdCliente()) %></p>
        <p><strong>Última reserva (pacote):</strong> <% String u = clienteCRUD.findLatestReservaNameByCliente(clienteSel.getIdCliente()); %><%= u != null && !u.isEmpty() ? u : "—" %></p>
        <%
        List<Reserva> reservasCliente = reservaCRUD.findByCliente(clienteSel.getIdCliente());
        if (reservasCliente != null && !reservasCliente.isEmpty()) {
        %>
        <div class="flow" style="margin-top: 1rem;">
            <h3 style="font-size: 1rem;">Reservas</h3>
            <ul class="public-info-card__list">
                <% for (Reserva rc : reservasCliente) {
                    Pacote pk = rc.getIdPacote() > 0 ? pacoteCRUD.findById(rc.getIdPacote()) : pacoteCRUD.findByReserva(rc.getIdReserva());
                    String pkNome = pk != null && pk.getNome() != null ? pk.getNome() : "Reserva #" + rc.getIdReserva();
                    List<Pagamento> pagos = pagamentoCRUD.findByReserva(rc.getIdReserva());
                %>
                <li><strong><%= pkNome %></strong> — <%= rc.getEstado() != null ? rc.getEstado() : "" %> · <%= currencyFmt.format(rc.getTotalPagar()) %><% if (!pagos.isEmpty()) { %> · <%= pagos.get(0).getMetodo() != null ? pagos.get(0).getMetodo() : "" %><% } %></li>
                <% } %>
            </ul>
        </div>
        <% } %>
    </div>
</div>
<% } %>

</div>

<% if (clienteSel != null) { %>
<script>
(function() {
  var base = document.getElementById('staffClientsRoot').getAttribute('data-clients-base') || '';
  var backdrop = document.getElementById('staffClientsBackdrop');
  var drawer = document.getElementById('staffClientsDrawer');
  var btn = document.getElementById('staffClientsClose');
  function closeAll() {
    window.location.href = base;
  }
  if (backdrop) {
    backdrop.addEventListener('click', function(ev) {
      if (ev.target === backdrop) closeAll();
    });
  }
  if (btn) btn.addEventListener('click', function(ev) { ev.preventDefault(); closeAll(); });
  document.addEventListener('keydown', function(ev) {
    if (ev.key === 'Escape') closeAll();
  });
})();
</script>
<% } %>
