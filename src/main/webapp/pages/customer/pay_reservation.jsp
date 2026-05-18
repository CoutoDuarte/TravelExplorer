<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Connection.Classes.Cliente" %>
<%@ page import="Connection.Classes.Pacote" %>
<%@ page import="Connection.Classes.Pagamento" %>
<%@ page import="Connection.Classes.Reserva" %>
<%@ page import="Connection.CRUD.ClienteCRUD" %>
<%@ page import="Connection.CRUD.PacoteCRUD" %>
<%@ page import="Connection.CRUD.PagamentoCRUD" %>
<%@ page import="Connection.CRUD.ReservaCRUD" %>
<%!
private String escapeHtml(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
}
private boolean hasText(String value) {
    return value != null && !value.trim().isEmpty();
}
private String formatDate(java.time.LocalDate date, DateTimeFormatter formatter) {
    if (date == null) return "";
    return date.format(formatter);
}
%>
<%
Object userIdObj = session.getAttribute("userId");
Integer idCliente = null;
if (userIdObj != null) {
    try { idCliente = Integer.valueOf(userIdObj.toString()); } catch (NumberFormatException ignored) {}
}
Integer idReserva = null;
String idReservaParam = request.getParameter("idReserva");
if (idReservaParam != null && !idReservaParam.trim().isEmpty()) {
    try { idReserva = Integer.valueOf(idReservaParam); } catch (NumberFormatException ignored) {}
}
Locale ptLocale = new Locale("pt", "PT");
NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(ptLocale);
DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy", ptLocale);
String ctx = request.getContextPath();
String error = request.getParameter("error");
Reserva reserva = null;
Pacote pacote = null;
Pagamento pagamento = null;
Cliente cliente = null;
String pageMode = "error";
String titulo = "";
String route = "";
String dates = "";
String travelersText = "";
String total = "";
String dataNascText = "";
String detailsUrl = ctx + "/index.jsp?page=my-reservations";
if (idCliente == null) {
    pageMode = "error";
} else if (idReserva == null) {
    pageMode = "error";
} else {
    detailsUrl = ctx + "/index.jsp?page=reservation-details&idReserva=" + idReserva;
    try {
        reserva = new ReservaCRUD().findByIdAndCliente(idReserva, idCliente);
        if (reserva == null) {
            pageMode = "error";
        } else {
            cliente = new ClienteCRUD().findById(idCliente);
            pacote = new PacoteCRUD().findByReserva(idReserva);
            pagamento = new PagamentoCRUD().findFirstByReserva(idReserva);
            if (cliente == null || !cliente.hasBillingComplete()) {
                pageMode = "billing";
            } else if (!cliente.isAtLeast18()) {
                pageMode = "underage";
            } else if (pagamento == null) {
                pageMode = "error";
            } else {
                String estadoPag = pagamento.getEstado() != null ? pagamento.getEstado() : "Pendente";
                if ("Pago".equalsIgnoreCase(estadoPag.trim())) {
                    pageMode = "paid";
                } else {
                    pageMode = "checkout";
                }
            }
        }
    } catch (Exception e) {
        pageMode = "error";
    }
}
if (reserva != null) {
    titulo = hasText(reserva.getTitulo()) ? reserva.getTitulo() : (pacote != null && hasText(pacote.getNome()) ? pacote.getNome() : "Reserva #" + reserva.getIdReserva());
    String orig = hasText(reserva.getOrigem()) ? reserva.getOrigem() : "—";
    String dest = hasText(reserva.getDestino()) ? reserva.getDestino() : "—";
    route = orig + " → " + dest;
    if (reserva.getDataPartida() != null || reserva.getDataRegresso() != null) {
        dates = formatDate(reserva.getDataPartida(), dateFormatter);
        if (reserva.getDataRegresso() != null) {
            dates += " – " + formatDate(reserva.getDataRegresso(), dateFormatter);
        }
    }
    int adultos = reserva.getAdultos() > 0 ? reserva.getAdultos() : (pacote != null ? pacote.getNumAdultos() : 1);
    int criancas = reserva.getCriancas() >= 0 ? reserva.getCriancas() : (pacote != null ? pacote.getNumCriancas() : 0);
    int totalViaj = adultos + criancas;
    travelersText = totalViaj + (totalViaj == 1 ? " viajante" : " viajantes");
    total = currencyFormat.format(reserva.getTotalPagar());
}
if (cliente != null && cliente.getDataNasc() != null) {
    dataNascText = cliente.getDataNasc().format(dateFormatter);
}
%>

<div class="te-page-shell te-page-shell--pay">
    <header class="te-page-header">
        <p class="te-page-eyebrow">Pagamento</p>
        <h1 class="te-page-title">Pagamento da reserva</h1>
        <p class="te-page-subtitle">Confirma os dados e escolhe um método de pagamento simulado.</p>
    </header>

    <% if ("invalid-data".equals(error)) { %>
    <div class="te-alert te-alert--warn">Seleciona um método de pagamento para continuar.</div>
    <% } else if ("payment-failed".equals(error)) { %>
    <div class="te-alert te-alert--warn">Não foi possível concluir o pagamento. Tenta novamente.</div>
    <% } %>

    <% if ("error".equals(pageMode)) { %>
    <div class="te-booking-card te-booking-card--center">
        <h2 class="te-booking-card__header">Não foi possível continuar</h2>
        <p class="te-booking-value">Verifica se a reserva existe e se tens sessão iniciada.</p>
        <div class="te-pay-actions">
            <a class="btn btn-secondary" href="<%= ctx %>/index.jsp?page=my-reservations">As minhas reservas</a>
        </div>
    </div>
    <% } else if ("billing".equals(pageMode)) { %>
    <div class="te-alert te-alert--warn">Antes de pagar, completa os teus dados de faturação.</div>
    <div class="te-booking-card te-booking-card--center">
        <h2 class="te-booking-card__header">Dados em falta</h2>
        <p class="te-booking-value">É necessário indicar morada, NIF e data de nascimento.</p>
        <div class="te-pay-actions">
            <a class="btn btn-primary" href="<%= ctx %>/index.jsp?page=billing-details&amp;idReserva=<%= idReserva %>&amp;returnTo=pay">Completar faturação</a>
            <a class="btn btn-ghost" href="<%= detailsUrl %>">Voltar à reserva</a>
        </div>
    </div>
    <% } else if ("underage".equals(pageMode) || "underage".equals(error)) { %>
    <div class="te-booking-card te-booking-card--center te-booking-card--blocked">
        <h2 class="te-booking-card__header">Pagamento indisponível</h2>
        <p class="te-booking-value">É necessário ter pelo menos 18 anos para concluir uma reserva.</p>
        <div class="te-pay-actions">
            <a class="btn btn-primary" href="<%= detailsUrl %>">Voltar à reserva</a>
        </div>
    </div>
    <% } else if ("paid".equals(pageMode)) { %>
    <div class="te-alert te-alert--success">Esta reserva já está paga.</div>
    <div class="te-pay-actions">
        <a class="btn btn-primary" href="<%= detailsUrl %>">Ver reserva</a>
    </div>
    <% } else if ("checkout".equals(pageMode) && reserva != null && cliente != null) { %>

    <div class="te-pay-top-grid">
        <article class="te-booking-card">
            <h2 class="te-booking-card__header">Resumo da reserva</h2>
            <p class="te-pay-trip-title"><%= escapeHtml(titulo) %></p>
            <dl class="te-booking-kv">
                <div><dt class="te-booking-label">Rota</dt><dd class="te-booking-value"><%= escapeHtml(route) %></dd></div>
                <div><dt class="te-booking-label">Datas</dt><dd class="te-booking-value"><%= escapeHtml(hasText(dates) ? dates : "Por definir") %></dd></div>
                <div><dt class="te-booking-label">Viajantes</dt><dd class="te-booking-value"><%= escapeHtml(travelersText) %></dd></div>
                <div><dt class="te-booking-label">Total</dt><dd class="te-booking-value te-booking-value--price"><%= escapeHtml(total) %></dd></div>
            </dl>
        </article>

        <article class="te-booking-card">
            <h2 class="te-booking-card__header">Dados de faturação</h2>
            <dl class="te-booking-kv">
                <div><dt class="te-booking-label">Nome</dt><dd class="te-booking-value"><%= escapeHtml(cliente.getNome()) %></dd></div>
                <div><dt class="te-booking-label">Morada</dt><dd class="te-booking-value"><%= escapeHtml(cliente.getMorada()) %></dd></div>
                <div><dt class="te-booking-label">NIF</dt><dd class="te-booking-value"><%= cliente.getNIF() %></dd></div>
                <% if (hasText(dataNascText)) { %>
                <div><dt class="te-booking-label">Data de nascimento</dt><dd class="te-booking-value"><%= escapeHtml(dataNascText) %></dd></div>
                <% } %>
            </dl>
            <a class="btn btn-ghost te-pay-edit-billing" href="<%= ctx %>/index.jsp?page=billing-details&amp;idReserva=<%= idReserva %>&amp;returnTo=pay">Alterar dados</a>
        </article>
    </div>

    <form class="te-pay-form" method="post" action="<%= ctx %>/pagar-reserva" id="pay-reservation-form">
        <input type="hidden" name="idReserva" value="<%= idReserva %>">
        <article class="te-booking-card">
            <h2 class="te-booking-card__header">Método de pagamento</h2>
            <p class="te-booking-card__sub">Escolhe como queres simular o pagamento.</p>
            <div class="te-payment-method-grid" id="payment-method-grid">
                <label class="te-payment-method">
                    <input type="radio" name="metodo" value="Cartão" required>
                    <span class="te-payment-method__content">
                        <span class="te-payment-method__title">Cartão</span>
                        <span class="te-payment-method__hint">Pagamento simulado por cartão</span>
                    </span>
                </label>
                <label class="te-payment-method">
                    <input type="radio" name="metodo" value="MB WAY">
                    <span class="te-payment-method__content">
                        <span class="te-payment-method__title">MB WAY</span>
                        <span class="te-payment-method__hint">Confirmação simulada por telemóvel</span>
                    </span>
                </label>
                <label class="te-payment-method">
                    <input type="radio" name="metodo" value="Transferência">
                    <span class="te-payment-method__content">
                        <span class="te-payment-method__title">Transferência</span>
                        <span class="te-payment-method__hint">Referência gerada automaticamente</span>
                    </span>
                </label>
            </div>
        </article>

        <footer class="te-pay-footer">
            <p class="te-pay-footer__note">Este pagamento é apenas uma simulação académica.</p>
            <div class="te-pay-footer__actions">
                <a class="btn btn-secondary" href="<%= detailsUrl %>">Cancelar</a>
                <button type="submit" class="btn btn-primary">Confirmar pagamento</button>
            </div>
        </footer>
    </form>
    <% } %>
</div>
