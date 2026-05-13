<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Connection.Classes.Cliente" %>
<%@ page import="Connection.Classes.Reserva" %>
<%@ page import="Connection.Classes.Pagamento" %>
<%@ page import="Connection.Classes.Pacote" %>
<%@ page import="Connection.Classes.Viagens" %>
<%@ page import="Connection.CRUD.ClienteCRUD" %>
<%@ page import="Connection.CRUD.ReservaCRUD" %>
<%@ page import="Connection.CRUD.PagamentoCRUD" %>
<%@ page import="Connection.CRUD.PacoteCRUD" %>
<%@ page import="Connection.CRUD.ViagemCRUD" %>
<%!
private String escapeHtml(String value) {
    if (value == null) {
        return "";
    }
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
}

private boolean hasText(String value) {
    return value != null && !value.trim().isEmpty();
}

private String formatDate(Timestamp timestamp, DateTimeFormatter formatter) {
    if (timestamp == null) {
        return "";
    }
    return timestamp.toLocalDateTime().format(formatter);
}

private String formatDates(Timestamp start, Timestamp end, DateTimeFormatter formatter) {
    if (start == null && end == null) {
        return "Datas por definir";
    }
    if (start != null && end != null) {
        return formatDate(start, formatter) + " - " + formatDate(end, formatter);
    }
    return start != null ? formatDate(start, formatter) : formatDate(end, formatter);
}
%>
<%
Object userIdObj = session.getAttribute("userId");
Integer idCliente = null;
if (userIdObj != null) {
    try {
        idCliente = Integer.valueOf(userIdObj.toString());
    } catch (NumberFormatException ignored) {
        idCliente = null;
    }
}
if (idCliente == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp?page=login");
    return;
}

Locale ptLocale = new Locale("pt", "PT");
NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(ptLocale);
DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy", ptLocale);
Cliente cliente = null;
int totalReservations = 0;
int activeReservations = 0;
double totalPaidValue = 0;
List<Reserva> latestReservations = new java.util.ArrayList<Reserva>();
String technicalError = null;
ClienteCRUD clienteCRUD = new ClienteCRUD();
ReservaCRUD reservaCRUD = new ReservaCRUD();
PagamentoCRUD pagamentoCRUD = new PagamentoCRUD();
PacoteCRUD pacoteCRUD = new PacoteCRUD();
ViagemCRUD viagemCRUD = new ViagemCRUD();

try {
    cliente = clienteCRUD.findById(idCliente);
    totalReservations = reservaCRUD.countByCliente(idCliente);
    activeReservations = reservaCRUD.countAtivasByCliente(idCliente);
    totalPaidValue = pagamentoCRUD.sumValorByCliente(idCliente);
    latestReservations = reservaCRUD.findLatestByCliente(idCliente, 3);
} catch (Exception e) {
    technicalError = "Erro técnico: " + e.getMessage();
}

String customerName = cliente != null ? cliente.getNome() : "";
String heading = hasText(customerName) ? "Bem-vindo, " + escapeHtml(customerName) : "Bem-vindo à tua área de cliente";
String totalPaid = currencyFormat.format(totalPaidValue);
%>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Dashboard" />
        <jsp:param name="heading" value="<%= heading %>" />
        <jsp:param name="description" value="Consulta rapidamente o estado das tuas reservas, pagamentos e próximos passos." />
    </jsp:include>

    <% if (technicalError != null) { %>
        <div class="surface-block">
            <p class="text-muted"><%= escapeHtml(technicalError) %></p>
        </div>
    <% } %>

    <div class="customer-dashboard-grid">
        <div class="surface-block customer-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Reservas</span>
                <h2 style="font-size: 1.25rem;"><%= totalReservations %> <%= totalReservations == 1 ? "reserva" : "reservas" %></h2>
                <p class="text-muted">Acompanha todas as reservas associadas à tua conta.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=my-reservations">Ver reservas</a>
            </div>
        </div>

        <div class="surface-block customer-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Ativas</span>
                <h2 style="font-size: 1.25rem;"><%= activeReservations %> <%= activeReservations == 1 ? "reserva ativa" : "reservas ativas" %></h2>
                <p class="text-muted">Consulta viagens ainda em preparação ou acompanhamento.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=my-reservations">Ver ativas</a>
            </div>
        </div>

        <div class="surface-block customer-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Pagamentos</span>
                <h2 style="font-size: 1.25rem;"><%= escapeHtml(totalPaid) %></h2>
                <p class="text-muted">Total pago nas reservas registadas na tua conta.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=my-reservations">Ver detalhes</a>
            </div>
        </div>
    </div>

    <div class="surface-block surface-block-lg customer-action-panel">
        <div class="flow">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Próximos passos" />
                <jsp:param name="heading" value="Reservas mais recentes" />
                <jsp:param name="description" value="Consulta rapidamente as reservas mais recentes associadas à tua conta." />
            </jsp:include>

            <% if (latestReservations.isEmpty()) { %>
                <p class="text-muted">Ainda não existem reservas associadas à tua conta.</p>
            <% } else { %>
                <div class="customer-dashboard-grid">
                    <% for (Reserva reservation : latestReservations) {
                        Pacote pacote = pacoteCRUD.findByReserva(reservation.getIdReserva());
                        List<Viagens> viagens = pacote != null ? viagemCRUD.findByPacote(pacote.getIdPacote()) : new java.util.ArrayList<Viagens>();
                        Viagens primeiraViagem = viagens.isEmpty() ? null : viagens.get(0);
                        Viagens ultimaViagem = viagens.isEmpty() ? null : viagens.get(viagens.size() - 1);
                        String title = pacote != null && hasText(pacote.getNome()) ? pacote.getNome() : "Reserva #" + reservation.getIdReserva();
                        String destination = primeiraViagem != null && hasText(primeiraViagem.getDestino()) ? primeiraViagem.getDestino() : "Destino por definir";
                        String dates = formatDates(primeiraViagem != null ? primeiraViagem.getDataHoraPartida() : null, ultimaViagem != null ? ultimaViagem.getDataHoraRegresso() : null, dateFormatter);
                        int travelers = pacote != null ? pacote.getNumAdultos() + pacote.getNumCriancas() : 0;
                        int displayTravelers = travelers > 0 ? travelers : 1;
                        String travelersText = displayTravelers + (displayTravelers == 1 ? " viajante" : " viajantes");
                        String status = hasText(reservation.getEstado()) ? reservation.getEstado() : "Estado por definir";
                    %>
                        <article class="surface-block customer-summary-card">
                            <div class="flow">
                                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                                    <div class="flow" style="gap: 0.45rem;">
                                        <span class="section-title__eyebrow"><%= escapeHtml(status) %></span>
                                        <h2 style="font-size: 1.2rem;"><%= escapeHtml(title) %></h2>
                                    </div>
                                    <span class="card__tag">RES-<%= reservation.getIdReserva() %></span>
                                </div>
                                <div class="flow" style="gap: 0.65rem;">
                                    <p class="text-muted"><strong>Destino:</strong> <%= escapeHtml(destination) %></p>
                                    <p class="text-muted"><strong>Datas:</strong> <%= escapeHtml(dates) %></p>
                                    <p class="text-muted"><strong>Viajantes:</strong> <%= escapeHtml(travelersText) %></p>
                                </div>
                                <div class="actions-row">
                                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=reservation-details&idReserva=<%= reservation.getIdReserva() %>">Ver detalhes</a>
                                </div>
                            </div>
                        </article>
                    <% } %>
                </div>
            <% } %>

            <div class="actions-row">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/index.jsp?page=offers">Explorar ofertas</a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=profile">Gerir conta</a>
            </div>
        </div>
    </div>
</div>