<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.text.NumberFormat,java.util.Locale,java.time.format.DateTimeFormatter,Connection.Classes.Cliente,Connection.Classes.Reserva,Connection.Classes.Pacote,Connection.Classes.Pagamento,Connection.Classes.Viagens,Connection.Classes.Alojamento,Connection.Classes.Transporte,Connection.CRUD.ClienteCRUD,Connection.CRUD.ReservaCRUD,Connection.CRUD.PacoteCRUD,Connection.CRUD.PagamentoCRUD,Connection.CRUD.ViagemCRUD,Connection.CRUD.AlojamentoCRUD,Connection.CRUD.TransporteCRUD" %>
<%
ClienteCRUD clienteCRUD = new ClienteCRUD();
ReservaCRUD reservaCRUD = new ReservaCRUD();
PacoteCRUD pacoteCRUD = new PacoteCRUD();
PagamentoCRUD pagamentoCRUD = new PagamentoCRUD();
ViagemCRUD viagemCRUD = new ViagemCRUD();
AlojamentoCRUD alojamentoCRUD = new AlojamentoCRUD();
TransporteCRUD transporteCRUD = new TransporteCRUD();
DateTimeFormatter dfRes = DateTimeFormatter.ofPattern("dd/MM/yyyy").withLocale(new Locale("pt", "PT"));
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
String reservasBase = request.getContextPath() + "/index.jsp?page=staff-reservations";
String commBase = request.getContextPath() + "/index.jsp?page=staff-communication";
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
                        <th>Total reservas</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Cliente c : clientes) {
                        int nRes = clienteCRUD.countReservasByCliente(c.getIdCliente());
                    %>
                    <tr>
                        <td><strong><%= c.getNome() != null ? c.getNome() : "" %></strong></td>
                        <td><%= c.getEmail() != null ? c.getEmail() : "" %></td>
                        <td><%= c.getTelemovel() %></td>
                        <td><%= c.getNIF() > 0 ? String.valueOf(c.getNIF()) : "—" %></td>
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
        <div class="actions-row">
            <a class="btn btn-secondary" href="<%= commBase %>&amp;clienteFilter=<%= clienteSel.getIdCliente() %>">Comunicação</a>
        </div>
        <%
        List<Reserva> reservasCliente = reservaCRUD.findByCliente(clienteSel.getIdCliente());
        if (reservasCliente != null && !reservasCliente.isEmpty()) {
        %>
        <div class="flow" style="margin-top: 1rem;">
            <h3 style="font-size: 1rem;">Reservas do cliente</h3>
            <% for (Reserva rc : reservasCliente) {
                Pacote pk = pacoteCRUD.findByReserva(rc.getIdReserva());
                if (pk == null && rc.getIdPacote() > 0) pk = pacoteCRUD.findById(rc.getIdPacote());
                String titulo = rc.getTitulo() != null && !rc.getTitulo().isEmpty() ? rc.getTitulo() : (pk != null && pk.getNome() != null ? pk.getNome() : "Reserva #" + rc.getIdReserva());
                String rota = (rc.getOrigem() != null ? rc.getOrigem() : "—") + " → " + (rc.getDestino() != null ? rc.getDestino() : "—");
                String datas = "";
                if (rc.getDataPartida() != null) {
                    datas = rc.getDataPartida().format(dfRes);
                    if (rc.getDataRegresso() != null) datas += " - " + rc.getDataRegresso().format(dfRes);
                }
                Pagamento pag = pagamentoCRUD.findFirstByReserva(rc.getIdReserva());
                String pagEstado = pag != null && pag.getEstado() != null ? pag.getEstado() : "Pendente";
                List<Viagens> viagens = pk != null ? viagemCRUD.findByPacote(pk.getIdPacote()) : new java.util.ArrayList<Viagens>();
                List<Alojamento> alojamentos = pk != null ? alojamentoCRUD.findByPacote(pk.getIdPacote()) : new java.util.ArrayList<Alojamento>();
                List<Transporte> transportes = pk != null ? transporteCRUD.findByPacote(pk.getIdPacote()) : new java.util.ArrayList<Transporte>();
            %>
            <div class="surface-block" style="margin-top: 0.75rem;">
                <p><strong>RES-<%= rc.getIdReserva() %> · <%= titulo %></strong></p>
                <p class="text-muted"><strong>Rota:</strong> <%= rota %></p>
                <% if (!datas.isEmpty()) { %><p class="text-muted"><strong>Datas:</strong> <%= datas %></p><% } %>
                <p class="text-muted"><strong>Total:</strong> <%= currencyFmt.format(rc.getTotalPagar()) %> · <strong>Estado:</strong> <%= rc.getEstado() != null ? rc.getEstado() : "" %> · <strong>Pagamento:</strong> <%= pagEstado %></p>
                <% if (!viagens.isEmpty()) { %>
                <p class="text-muted"><strong>Voos:</strong>
                <% for (int i = 0; i < viagens.size(); i++) {
                    Viagens v = viagens.get(i);
                    if (i > 0) { %>; <% }
                %><%= v.getEmpresa() != null ? v.getEmpresa() : "" %> <%= v.getDescricao() != null ? v.getDescricao() : "" %> (<%= v.getOrigem() %>→<%= v.getDestino() %>)<% } %>
                </p>
                <% } %>
                <% if (!alojamentos.isEmpty()) { %>
                <p class="text-muted"><strong>Alojamento:</strong> <%= alojamentos.get(0).getNome() %> · <%= alojamentos.get(0).getTipoEstadia() != null ? alojamentos.get(0).getTipoEstadia() : "Hotel" %></p>
                <% } %>
                <% if (!transportes.isEmpty()) {
                    Transporte t = transportes.get(0);
                %>
                <p class="text-muted"><strong>Transporte:</strong> <%= t.getTipo() != null ? t.getTipo() : "" %> <%= t.getOrigem() != null ? t.getOrigem() : "" %> → <%= t.getDestino() != null ? t.getDestino() : "" %></p>
                <% } %>
                <div class="actions-row" style="margin-top:0.5rem;">
                    <a class="btn btn-secondary" style="font-size:0.85rem;padding:0.35rem 0.65rem;" href="<%= reservasBase %>&amp;selectedReserva=<%= rc.getIdReserva() %>">Ver reserva</a>
                    <a class="btn btn-secondary" style="font-size:0.85rem;padding:0.35rem 0.65rem;" href="<%= commBase %>&amp;reservaFilter=<%= rc.getIdReserva() %>">Comunicação</a>
                </div>
            </div>
            <% } %>
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
