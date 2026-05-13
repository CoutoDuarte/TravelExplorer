<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" 
    import="java.text.NumberFormat,
    java.time.LocalDateTime,
    java.time.format.DateTimeFormatter,
    java.util.List,
    java.util.Locale,
    Connection.Classes.ClienteOfertaGuardada, 
    Connection.CRUD.ClienteOfertaGuardadaCRUD" %>
    
<%!
private String escapeHtml(String value) {
    if (value == null) {
        return "";
    }
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
}

private String safeValue(String value) {
    return value != null ? value : "";
}

private boolean hasText(String value) {
    return value != null && !value.trim().isEmpty();
}

private String formatDate(String value, DateTimeFormatter formatter) {
    if (!hasText(value)) {
        return "";
    }
    try {
        return LocalDateTime.parse(value).format(formatter);
    } catch (Exception e) {
        return value;
    }
}

private String formatDates(String start, String end, DateTimeFormatter formatter) {
    if (!hasText(start) && !hasText(end)) {
        return "";
    }
    if (hasText(start) && hasText(end)) {
        return formatDate(start, formatter) + " - " + formatDate(end, formatter);
    }
    return hasText(start) ? formatDate(start, formatter) : formatDate(end, formatter);
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
%>
<script>
    window.location.replace("<%= request.getContextPath() %>/index.jsp?page=login");
</script>
<%
    return;
}

String technicalError = null;
Locale ptLocale = new Locale("pt", "PT");
NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(ptLocale);
DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy", ptLocale);
DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm", ptLocale);
List<ClienteOfertaGuardada> savedOffers = new java.util.ArrayList<ClienteOfertaGuardada>();

try {
    savedOffers = ClienteOfertaGuardadaCRUD.listarPorCliente(idCliente);
} catch (Exception e) {
    technicalError = "Erro técnico: " + e.getMessage();
}

String errorParam = request.getParameter("error");
if (technicalError == null && hasText(errorParam)) {
    technicalError = "Erro técnico: " + errorParam;
}
%>
<style>
    .saved-offers-grid {
        align-items: start;
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .saved-offers-grid .card {
        height: auto;
        align-self: start;
    }

    @media (max-width: 900px) {
        .saved-offers-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Guardados" />
        <jsp:param name="heading" value="Ofertas guardadas" />
        <jsp:param name="description" value="Consulta rapidamente as ofertas que guardaste para comparar ou rever mais tarde." />
    </jsp:include>

    <div class="customer-dashboard-grid saved-offers-grid">
        <% if (technicalError != null) { %>
            <div class="surface-block">
                <p class="text-muted"><%= escapeHtml(technicalError) %></p>
            </div>
        <% } else if (savedOffers.isEmpty()) { %>
            <div class="surface-block">
                <p class="text-muted">Ainda não tens ofertas guardadas.</p>
            </div>
        <% } else { %>
            <% for (ClienteOfertaGuardada offer : savedOffers) {
                int travelers = offer.getNumeroPessoasAdultas() + offer.getNumeroCriancas();
                String travelersText = travelers + (travelers == 1 ? " viajante" : " viajantes");
                String datesText = formatDates(offer.getDataPartida(), offer.getDataRegresso(), dateFormatter);
                String savedDateText = formatDate(offer.getDataGuardado(), dateTimeFormatter);
                String priceText = currencyFormat.format(offer.getPrecoBase()).replace("€", "EUR");
            %>
                <article class="card">
                    <div class="card__media">
                        <img src="${pageContext.request.contextPath}/assets/img/offers/offer-1.jpg" alt="<%= escapeHtml(safeValue(offer.getNomePacote())) %>">
                    </div>

                    <div class="card__body">
                        <div class="card__meta">
                            <% if (hasText(offer.getDestino())) { %>
                                <span class="card__tag"><%= escapeHtml(offer.getDestino()) %></span>
                            <% } %>
                            <span class="card__tag"><%= escapeHtml(travelersText) %></span>
                        </div>

                        <h3 class="card__title"><%= escapeHtml(hasText(offer.getNomePacote()) ? offer.getNomePacote() : "Oferta sem nome") %></h3>

                        <div class="offer-card__meta-line">
                            <% if (hasText(offer.getOrigem())) { %>
                                <span>Origem: <%= escapeHtml(offer.getOrigem()) %></span>
                            <% } %>
                            <% if (hasText(offer.getDestino())) { %>
                                <span>Destino: <%= escapeHtml(offer.getDestino()) %></span>
                            <% } %>
                            <% if (hasText(offer.getTipoEstadia())) { %>
                                <span><%= escapeHtml(offer.getTipoEstadia()) %></span>
                            <% } %>
                        </div>

                        <p class="offer-card__description">
                            <%= escapeHtml(safeValue(offer.getDescricaoPacote())) %>
                        </p>

                        <div class="flow" style="gap: 0.55rem;">
                            <% if (hasText(datesText)) { %>
                                <p class="text-muted"><strong>Datas:</strong> <%= escapeHtml(datesText) %></p>
                            <% } %>
                            <p class="text-muted"><strong>Viajantes:</strong> <%= escapeHtml(travelersText) %></p>
                            <% if (hasText(savedDateText)) { %>
                                <p class="text-muted"><strong>Guardado em:</strong> <%= escapeHtml(savedDateText) %></p>
                            <% } %>
                        </div>

                        <div class="card__footer">
                            <span class="card__price"><%= escapeHtml(priceText) %></span>
                            <div class="actions-row">
                                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=offer-details&idPacote=<%= offer.getIdPacote() %>">
                                    Ver oferta
                                </a>
                                <form action="${pageContext.request.contextPath}/ClienteOfertaGuardadaServlet" method="post">
                                    <input type="hidden" name="action" value="remove">
                                    <input type="hidden" name="idPacote" value="<%= offer.getIdPacote() %>">
                                    <button class="btn btn-secondary" type="submit">Remover</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </article>
            <% } %>
        <% } %>
    </div>

    
</div>