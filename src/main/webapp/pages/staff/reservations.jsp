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
String clientsBase = request.getContextPath() + "/index.jsp?page=staff-clients";
%>

<div id="staffResRoot" class="staff-shell staff-offers-page" data-res-base="<%= request.getContextPath() %>/index.jsp?page=staff-reservations">

<div class="flow">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Reservas" />
        <jsp:param name="heading" value="Reservas dos clientes" />
        <jsp:param name="description" value="Lista apenas de consulta das reservas registadas na base de dados." />
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
                        String clienteLink = cl != null ? clientsBase + "&selectedCliente=" + cl.getIdCliente() : clientsBase;
                    %>
                    <tr>
                        <td><%= r.getIdReserva() %></td>
                        <td><%= dataTxt %></td>
                        <td><%= cliTxt %></td>
                        <td><%= pacTxt %></td>
                        <td><%= dfValor.format(r.getTotalPagar()) %> €</td>
                        <td><%= r.getEstado() != null ? r.getEstado() : "" %></td>
                        <td><a class="btn btn-secondary" style="padding: 0.35rem 0.65rem; font-size: 0.85rem;" href="<%= clienteLink %>">Ver cliente</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>

</div>
