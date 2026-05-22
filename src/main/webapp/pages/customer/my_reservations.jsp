<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Connection.Classes.Pacote" %>
<%@ page import="Connection.Classes.Reserva" %>
<%@ page import="Connection.Classes.Viagens" %>
<%@ page import="Connection.CRUD.PacoteCRUD" %>
<%@ page import="Connection.CRUD.ReservaCRUD" %>
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

DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy", new Locale("pt", "PT"));
String technicalError = null;
List<Reserva> reservations = new java.util.ArrayList<Reserva>();
ReservaCRUD reservaCRUD = new ReservaCRUD();
PacoteCRUD pacoteCRUD = new PacoteCRUD();
ViagemCRUD viagemCRUD = new ViagemCRUD();

try {
    reservations = reservaCRUD.findByCliente(idCliente);
} catch (Exception e) {
    technicalError = "Erro técnico: " + e.getMessage();
}
%>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Reservas" />
        <jsp:param name="heading" value="As minhas reservas" />
        <jsp:param name="description" value="Consulta rapidamente as tuas reservas atuais e acompanha o respetivo estado." />
    </jsp:include>

    <% if ("payment-done".equals(request.getParameter("success"))) { %>
    <div class="surface-block"><p class="text-muted">Pagamento confirmado. A tua reserva foi atualizada.</p></div>
    <% } %>
    <% if ("created".equals(request.getParameter("success"))) { %>
    <div class="surface-block public-search-alert--success"><p>Reserva criada com sucesso.</p></div>
    <% } %>

    <% if (technicalError != null) { %>
        <div class="surface-block">
            <p class="text-muted"><%= escapeHtml(technicalError) %></p>
        </div>
    <% } else if (reservations.isEmpty()) { %>
        <div class="surface-block">
            <p class="text-muted">Ainda não tens reservas registadas.</p>
        </div>
    <% } else { %>
        <div class="customer-dashboard-grid">
            <% for (Reserva reservation : reservations) {
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
                String statusParam = escapeHtml(status);
                String titleParam = escapeHtml(title);
                String referenceParam = "RES-" + reservation.getIdReserva();
                String destinationParam = escapeHtml(destination);
                String datesParam = escapeHtml(dates);
                String travelersParam = escapeHtml(travelersText);
                String detailsUrlParam = request.getContextPath() + "/index.jsp?page=reservation-details&idReserva=" + reservation.getIdReserva();
            %>
                <jsp:include page="/components/customer/reservation_card.jsp">
                    <jsp:param name="status" value="<%= statusParam %>" />
                    <jsp:param name="title" value="<%= titleParam %>" />
                    <jsp:param name="reference" value="<%= referenceParam %>" />
                    <jsp:param name="destination" value="<%= destinationParam %>" />
                    <jsp:param name="dates" value="<%= datesParam %>" />
                    <jsp:param name="travelers" value="<%= travelersParam %>" />
                    <jsp:param name="statusText" value="<%= statusParam %>" />
                    <jsp:param name="detailsUrl" value="<%= detailsUrlParam %>" />
                </jsp:include>
            <% } %>
        </div>
    <% } %>
</div>
