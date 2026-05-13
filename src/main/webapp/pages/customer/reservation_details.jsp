<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Connection.Classes.Alojamento" %>
<%@ page import="Connection.Classes.Pacote" %>
<%@ page import="Connection.Classes.Reserva" %>
<%@ page import="Connection.Classes.Transporte" %>
<%@ page import="Connection.Classes.Viagens" %>
<%@ page import="Connection.CRUD.AlojamentoCRUD" %>
<%@ page import="Connection.CRUD.PacoteCRUD" %>
<%@ page import="Connection.CRUD.ReservaCRUD" %>
<%@ page import="Connection.CRUD.TransporteCRUD" %>
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

private String formatDate(java.time.LocalDate date, DateTimeFormatter formatter) {
    if (date == null) {
        return "";
    }
    return date.format(formatter);
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

private String joinAlojamentos(List<Alojamento> alojamentos) {
    if (alojamentos == null || alojamentos.isEmpty()) {
        return "Alojamento por definir";
    }
    StringBuilder sb = new StringBuilder();
    for (Alojamento alojamento : alojamentos) {
        if (alojamento != null && hasText(alojamento.getNome())) {
            if (sb.length() > 0) {
                sb.append(", ");
            }
            sb.append(alojamento.getNome());
        }
    }
    return sb.length() > 0 ? sb.toString() : "Alojamento por definir";
}

private String joinTransportes(List<Transporte> transportes) {
    if (transportes == null || transportes.isEmpty()) {
        return "Transporte por definir";
    }
    StringBuilder sb = new StringBuilder();
    for (Transporte transporte : transportes) {
        if (transporte != null) {
            String value = (hasText(transporte.getTipo()) ? transporte.getTipo() : "") + (hasText(transporte.getEmpresa()) ? " " + transporte.getEmpresa() : "");
            if (hasText(value)) {
                if (sb.length() > 0) {
                    sb.append(", ");
                }
                sb.append(value.trim());
            }
        }
    }
    return sb.length() > 0 ? sb.toString() : "Transporte por definir";
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

Integer idReserva = null;
String idReservaParam = request.getParameter("idReserva");
if (idReservaParam != null && !idReservaParam.trim().isEmpty()) {
    try {
        idReserva = Integer.valueOf(idReservaParam);
    } catch (NumberFormatException ignored) {
        idReserva = null;
    }
}

Locale ptLocale = new Locale("pt", "PT");
NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(ptLocale);
DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy", ptLocale);
String technicalError = null;
String friendlyMessage = null;
Reserva reservation = null;
Pacote pacote = null;
List<Viagens> viagens = new java.util.ArrayList<Viagens>();
List<Alojamento> alojamentos = new java.util.ArrayList<Alojamento>();
List<Transporte> transportes = new java.util.ArrayList<Transporte>();
ReservaCRUD reservaCRUD = new ReservaCRUD();
PacoteCRUD pacoteCRUD = new PacoteCRUD();
ViagemCRUD viagemCRUD = new ViagemCRUD();
AlojamentoCRUD alojamentoCRUD = new AlojamentoCRUD();
TransporteCRUD transporteCRUD = new TransporteCRUD();

if (idReserva == null) {
    friendlyMessage = "Não foi possível identificar a reserva pedida.";
} else {
    try {
        reservation = reservaCRUD.findByIdAndCliente(idReserva, idCliente);
        if (reservation == null) {
            friendlyMessage = "Reserva não encontrada.";
        } else {
            pacote = pacoteCRUD.findByReserva(reservation.getIdReserva());
            if (pacote == null && reservation.getIdPacote() > 0) {
                pacote = pacoteCRUD.findById(reservation.getIdPacote());
            }
            if (pacote != null) {
                viagens = viagemCRUD.findByPacote(pacote.getIdPacote());
                alojamentos = alojamentoCRUD.findByPacote(pacote.getIdPacote());
                transportes = transporteCRUD.findByPacote(pacote.getIdPacote());
            }
        }
    } catch (Exception e) {
        technicalError = "Erro técnico: " + e.getMessage();
    }
}

String title = "";
String destination = "";
String dates = "";
String travelersText = "";
String status = "";
String alojamento = "";
String transporte = "";
String total = "";
String dataReserva = "";
if (reservation != null) {
    Viagens primeiraViagem = viagens.isEmpty() ? null : viagens.get(0);
    Viagens ultimaViagem = viagens.isEmpty() ? null : viagens.get(viagens.size() - 1);
    title = pacote != null && hasText(pacote.getNome()) ? pacote.getNome() : "Reserva #" + reservation.getIdReserva();
    destination = primeiraViagem != null && hasText(primeiraViagem.getDestino()) ? primeiraViagem.getDestino() : "Destino por definir";
    dates = formatDates(primeiraViagem != null ? primeiraViagem.getDataHoraPartida() : null, ultimaViagem != null ? ultimaViagem.getDataHoraRegresso() : null, dateFormatter);
    int travelers = pacote != null ? pacote.getNumAdultos() + pacote.getNumCriancas() : 0;
    int displayTravelers = travelers > 0 ? travelers : 1;
    travelersText = displayTravelers + (displayTravelers == 1 ? " viajante" : " viajantes");
    status = hasText(reservation.getEstado()) ? reservation.getEstado() : "Estado por definir";
    alojamento = joinAlojamentos(alojamentos);
    transporte = joinTransportes(transportes);
    total = currencyFormat.format(reservation.getTotalPagar());
    dataReserva = reservation.getDataReserva() != null ? formatDate(reservation.getDataReserva(), dateFormatter) : "Data por definir";
}
%>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Reserva" />
        <jsp:param name="heading" value="Detalhes da reserva" />
        <jsp:param name="description" value="Consulta o estado da reserva, informação principal e próximos passos." />
    </jsp:include>

    <% if (technicalError != null || friendlyMessage != null) { %>
        <div class="surface-block surface-block-lg customer-action-panel">
            <div class="flow">
                <p class="text-muted"><%= escapeHtml(technicalError != null ? technicalError : friendlyMessage) %></p>
                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=my-reservations">Voltar às reservas</a>
                </div>
            </div>
        </div>
    <% } else if (reservation != null) { %>
        <div class="surface-block surface-block-lg customer-action-panel">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow"><%= escapeHtml(status) %></span>
                        <h2 style="font-size: 1.45rem;"><%= escapeHtml(title) %></h2>
                    </div>

                    <span class="card__tag">RES-<%= reservation.getIdReserva() %></span>
                </div>

                <div class="customer-dashboard-grid">
                    <div>
                        <p class="text-muted"><strong>Destino:</strong> <%= escapeHtml(destination) %></p>
                    </div>
                    <div>
                        <p class="text-muted"><strong>Datas:</strong> <%= escapeHtml(dates) %></p>
                    </div>
                    <div>
                        <p class="text-muted"><strong>Viajantes:</strong> <%= escapeHtml(travelersText) %></p>
                    </div>
                </div>

                <div class="customer-dashboard-grid">
                    <div>
                        <p class="text-muted"><strong>Alojamento:</strong> <%= escapeHtml(alojamento) %></p>
                    </div>
                    <div>
                        <p class="text-muted"><strong>Transporte:</strong> <%= escapeHtml(transporte) %></p>
                    </div>
                    <div>
                        <p class="text-muted"><strong>Estado:</strong> <%= escapeHtml(status) %></p>
                    </div>
                </div>

                <div class="surface-block">
                    <div class="flow">
                        <span class="section-title__eyebrow">Resumo</span>
                        <p class="text-muted"><strong>Total:</strong> <%= escapeHtml(total) %></p>
                        <p class="text-muted"><strong>Data da reserva:</strong> <%= escapeHtml(dataReserva) %></p>
                    </div>
                </div>

                <div class="actions-row">
                    <a class="btn btn-primary" href="#">Transferir comprovativo</a>
                    <a class="btn btn-secondary" href="#">Contactar apoio</a>
                    <a class="btn btn-ghost" href="${pageContext.request.contextPath}/index.jsp?page=my-reservations">Voltar às reservas</a>
                </div>
            </div>
        </div>
    <% } %>
</div>