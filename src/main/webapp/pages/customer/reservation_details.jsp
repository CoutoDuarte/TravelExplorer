<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Connection.Classes.Alojamento" %>
<%@ page import="Connection.Classes.Comunicacao" %>
<%@ page import="Connection.Classes.Pacote" %>
<%@ page import="Connection.Classes.Pagamento" %>
<%@ page import="Connection.Classes.Reserva" %>
<%@ page import="Connection.Classes.Transporte" %>
<%@ page import="Connection.Classes.Viagens" %>
<%@ page import="Connection.CRUD.AlojamentoCRUD" %>
<%@ page import="Connection.CRUD.ComunicacaoCRUD" %>
<%@ page import="Connection.CRUD.PacoteCRUD" %>
<%@ page import="Connection.CRUD.PagamentoCRUD" %>
<%@ page import="Connection.CRUD.ReservaCRUD" %>
<%@ page import="Connection.CRUD.TransporteCRUD" %>
<%@ page import="Connection.CRUD.ViagemCRUD" %>
<%!
private String escapeHtml(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
}
private boolean hasText(String value) {
    return value != null && !value.trim().isEmpty();
}
private String formatDate(Timestamp timestamp, DateTimeFormatter formatter) {
    if (timestamp == null) return "";
    return timestamp.toLocalDateTime().format(formatter);
}
private String formatDate(java.time.LocalDate date, DateTimeFormatter formatter) {
    if (date == null) return "";
    return date.format(formatter);
}
private String formatTime(Timestamp timestamp, DateTimeFormatter formatter) {
    if (timestamp == null) return "";
    return timestamp.toLocalDateTime().format(formatter);
}
private String formatHotelCategory(Alojamento a) {
    if (a == null) return "Classificação não disponível";
    String estadia = a.getTipoEstadia();
    if (hasText(estadia) && !"Standard".equalsIgnoreCase(estadia.trim())) {
        if ("Hotel".equalsIgnoreCase(estadia.trim())) return "Hotel";
        return estadia.trim();
    }
    String quarto = a.getTipoQuarto();
    if (hasText(quarto) && !"Standard".equalsIgnoreCase(quarto.trim())) return quarto.trim();
    return "Classificação não disponível";
}
private String formatPagamentoMetodo(String metodo, boolean pago) {
    if (!hasText(metodo) || "Simulado".equalsIgnoreCase(metodo.trim())) {
        return pago ? null : "Por escolher";
    }
    return metodo.trim();
}
private java.util.List<Viagens> filterViagensByLeg(java.util.List<Viagens> viagens, String legPrefix) {
    java.util.List<Viagens> out = new java.util.ArrayList<Viagens>();
    if (viagens == null) return out;
    for (Viagens v : viagens) {
        if (v == null) continue;
        String desc = v.getDescricao() != null ? v.getDescricao() : "";
        if (desc.startsWith(legPrefix)) out.add(v);
    }
    return out;
}
private java.util.List<Viagens> filterViagensUnlabeled(java.util.List<Viagens> viagens) {
    java.util.List<Viagens> out = new java.util.ArrayList<Viagens>();
    if (viagens == null) return out;
    for (Viagens v : viagens) {
        if (v == null) continue;
        String desc = v.getDescricao() != null ? v.getDescricao() : "";
        if (!desc.startsWith("Ida") && !desc.startsWith("Regresso")) out.add(v);
    }
    return out;
}
private String flightSegmentTitle(Viagens v) {
    if (v == null) return "";
    String desc = v.getDescricao() != null ? v.getDescricao() : "";
    int segIdx = desc.indexOf("Segmento ");
    if (segIdx >= 0) {
        int end = desc.indexOf("·", segIdx);
        if (end > segIdx) return desc.substring(segIdx, end).trim();
        return desc.substring(segIdx).trim();
    }
    String orig = hasText(v.getOrigem()) ? v.getOrigem() : "—";
    String dest = hasText(v.getDestino()) ? v.getDestino() : "—";
    return orig + " → " + dest;
}
private String flightStopsLabel(java.util.List<Viagens> leg) {
    if (leg == null || leg.isEmpty()) return "Direto";
    int escalas = Math.max(0, leg.size() - 1);
    if (escalas == 0) return "Direto";
    if (escalas == 1) return "1 escala";
    return escalas + " escalas";
}
private String renderFlightTimelineItem(Viagens v, DateTimeFormatter timeFormatter, NumberFormat currencyFormat) {
    if (v == null) return "";
    StringBuilder sb = new StringBuilder();
    sb.append("<div class=\"te-flight-segment\">");
    sb.append("<div class=\"te-flight-segment__route\">").append(escapeHtml(flightSegmentTitle(v))).append("</div>");
    if (hasText(v.getEmpresa())) {
        sb.append("<p class=\"te-flight-segment__meta\">").append(escapeHtml(v.getEmpresa()));
        if (hasText(v.getDescricao()) && !v.getDescricao().contains("Segmento")) {
            sb.append(" · ").append(escapeHtml(v.getDescricao()));
        }
        sb.append("</p>");
    }
    String partida = formatTime(v.getDataHoraPartida(), timeFormatter);
    String chegada = formatTime(v.getDataHoraRegresso(), timeFormatter);
    if (hasText(partida) || hasText(chegada)) {
        sb.append("<p class=\"te-flight-segment__times\">");
        if (hasText(partida)) sb.append("Partida ").append(escapeHtml(partida));
        if (hasText(partida) && hasText(chegada)) sb.append(" · ");
        if (hasText(chegada)) sb.append("Chegada ").append(escapeHtml(chegada));
        sb.append("</p>");
    }
    if (v.getPreco() > 0) {
        sb.append("<p class=\"te-flight-segment__price\">").append(escapeHtml(currencyFormat.format(v.getPreco()))).append("</p>");
    }
    sb.append("</div>");
    return sb.toString();
}
private java.util.List<String> parseAtividadesFromDescricao(String descricao) {
    java.util.List<String> items = new java.util.ArrayList<String>();
    if (!hasText(descricao)) return items;
    int idx = descricao.indexOf("Atividades sugeridas:");
    if (idx < 0) return items;
    String section = descricao.substring(idx + "Atividades sugeridas:".length());
    int transp = section.indexOf("Transporte sugerido:");
    if (transp >= 0) section = section.substring(0, transp);
    for (String line : section.split("\\n")) {
        String trimmed = line != null ? line.trim() : "";
        if (trimmed.startsWith("- ")) trimmed = trimmed.substring(2).trim();
        if (!trimmed.isEmpty()) items.add(trimmed);
    }
    return items;
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
DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm", ptLocale);
java.util.List<String> atividadesLista = new java.util.ArrayList<String>();
String ctx = request.getContextPath();
String success = request.getParameter("success");
String error = request.getParameter("error");
Reserva reservation = null;
Pacote pacote = null;
Pagamento pagamento = null;
Comunicacao suporte = null;
List<Viagens> viagens = new java.util.ArrayList<Viagens>();
List<Alojamento> alojamentos = new java.util.ArrayList<Alojamento>();
List<Transporte> transportes = new java.util.ArrayList<Transporte>();
String friendlyMessage = null;
if (idCliente == null) {
    friendlyMessage = "Inicia sessão para ver os detalhes da reserva.";
} else if (idReserva == null) {
    friendlyMessage = "Não foi possível identificar a reserva pedida.";
} else {
    try {
        reservation = new ReservaCRUD().findByIdAndCliente(idReserva, idCliente);
        if (reservation == null) {
            friendlyMessage = "Reserva não encontrada.";
        } else {
            pacote = new PacoteCRUD().findByReserva(reservation.getIdReserva());
            if (pacote == null && reservation.getIdPacote() > 0) {
                pacote = new PacoteCRUD().findById(reservation.getIdPacote());
            }
            pagamento = new PagamentoCRUD().findFirstByReserva(idReserva);
            suporte = new ComunicacaoCRUD().findByReserva(idReserva);
            if (pacote != null) {
                viagens = new ViagemCRUD().findByPacote(pacote.getIdPacote());
                alojamentos = new AlojamentoCRUD().findByPacote(pacote.getIdPacote());
                transportes = new TransporteCRUD().findByPacote(pacote.getIdPacote());
            }
        }
    } catch (Exception e) {
        friendlyMessage = "Erro técnico: " + e.getMessage();
    }
}
String title = "";
String route = "";
String dates = "";
String travelersText = "";
String status = "";
String total = "";
String pagEstado = "Pendente";
String pagMetodoDisplay = null;
String pagValor = "";
String pagReferencia = "";
String pagData = "";
boolean pagamentoPago = false;
boolean suporteRespondido = false;
if (reservation != null) {
    title = hasText(reservation.getTitulo()) ? reservation.getTitulo() : (pacote != null && hasText(pacote.getNome()) ? pacote.getNome() : "Reserva #" + reservation.getIdReserva());
    String orig = hasText(reservation.getOrigem()) ? reservation.getOrigem() : null;
    String dest = hasText(reservation.getDestino()) ? reservation.getDestino() : null;
    if (orig == null && !viagens.isEmpty() && viagens.get(0) != null) orig = viagens.get(0).getOrigem();
    if (dest == null && !viagens.isEmpty()) {
        Viagens lastV = viagens.get(viagens.size() - 1);
        if (lastV != null) dest = lastV.getDestino();
    }
    route = (orig != null ? orig : "—") + " → " + (dest != null ? dest : "—");
    if (reservation.getDataPartida() != null || reservation.getDataRegresso() != null) {
        dates = formatDate(reservation.getDataPartida(), dateFormatter);
        if (reservation.getDataRegresso() != null) {
            dates += " – " + formatDate(reservation.getDataRegresso(), dateFormatter);
        }
    }
    int adultos = reservation.getAdultos() > 0 ? reservation.getAdultos() : (pacote != null ? pacote.getNumAdultos() : 1);
    int criancas = reservation.getCriancas() >= 0 ? reservation.getCriancas() : (pacote != null ? pacote.getNumCriancas() : 0);
    int totalViaj = adultos + criancas;
    travelersText = totalViaj + (totalViaj == 1 ? " viajante" : " viajantes");
    status = hasText(reservation.getEstado()) ? reservation.getEstado() : "Pendente";
    total = currencyFormat.format(reservation.getTotalPagar());
    if (pagamento != null) {
        pagEstado = hasText(pagamento.getEstado()) ? pagamento.getEstado() : "Pendente";
        pagamentoPago = "Pago".equalsIgnoreCase(pagEstado.trim());
        pagMetodoDisplay = formatPagamentoMetodo(pagamento.getMetodo(), pagamentoPago);
        pagValor = currencyFormat.format(pagamento.getValor());
        if (hasText(pagamento.getReferencia())) pagReferencia = pagamento.getReferencia();
        if (pagamento.getDataPagamento() != null) pagData = pagamento.getDataPagamento().toString();
    }
    if (suporte != null) {
        suporteRespondido = suporte.getResposta() != null && !suporte.getResposta().trim().isEmpty();
    }
    if (pacote != null && hasText(pacote.getDescricao())) {
        atividadesLista = parseAtividadesFromDescricao(pacote.getDescricao());
    }
}
java.util.List<Viagens> voosIda = filterViagensByLeg(viagens, "Ida");
java.util.List<Viagens> voosRegresso = filterViagensByLeg(viagens, "Regresso");
java.util.List<Viagens> voosOutros = filterViagensUnlabeled(viagens);
if (voosIda.isEmpty() && voosRegresso.isEmpty() && !viagens.isEmpty()) {
    int half = (viagens.size() + 1) / 2;
    voosIda = new java.util.ArrayList<Viagens>(viagens.subList(0, Math.min(half, viagens.size())));
    if (viagens.size() > half) {
        voosRegresso = new java.util.ArrayList<Viagens>(viagens.subList(half, viagens.size()));
    }
    voosOutros = new java.util.ArrayList<Viagens>();
}
%>

<div class="te-page-shell te-page-shell--details">
    <% if (friendlyMessage != null) { %>
    <div class="te-booking-card te-booking-card--center">
        <p class="te-booking-value"><%= escapeHtml(friendlyMessage) %></p>
        <a class="btn btn-secondary" href="<%= ctx %>/index.jsp?page=my-reservations">Voltar às reservas</a>
    </div>
    <% } else if (reservation != null) { %>

    <% if ("payment-done".equals(success) || "success".equals(request.getParameter("payment"))) { %>
    <div class="te-alert te-alert--success">Pagamento confirmado com sucesso.</div>
    <% } else if ("support-sent".equals(success)) { %>
    <div class="te-alert te-alert--success">Pedido enviado. A equipa responderá em breve.</div>
    <% } %>
    <% if ("empty-message".equals(error)) { %>
    <div class="te-alert te-alert--warn">Escreve uma mensagem antes de enviar.</div>
    <% } %>

    <section class="te-booking-hero">
        <div class="te-booking-hero__main">
            <span class="te-booking-hero__pill"><%= escapeHtml(status) %></span>
            <h1 class="te-booking-hero__title"><%= escapeHtml(title) %></h1>
            <p class="te-booking-hero__route"><%= escapeHtml(route) %></p>
            <div class="te-booking-hero__meta">
                <span><%= escapeHtml(hasText(dates) ? dates : "Datas por definir") %></span>
                <span><%= escapeHtml(travelersText) %></span>
                <span>RES-<%= reservation.getIdReserva() %></span>
            </div>
        </div>
        <div class="te-booking-hero__price">
            <span class="te-booking-label">Total</span>
            <strong class="te-booking-hero__amount"><%= escapeHtml(total) %></strong>
            <span class="te-booking-hero__pay"><%= pagamentoPago ? "Pagamento concluído" : "Pagamento pendente" %></span>
            <% if (!pagamentoPago) { %>
            <a class="btn btn-primary" href="<%= ctx %>/index.jsp?page=pay-reservation&amp;idReserva=<%= reservation.getIdReserva() %>">Pagar reserva</a>
            <% } else { %>
            <span class="te-booking-hero__done">Pagamento concluído</span>
            <% } %>
        </div>
    </section>

    <div class="te-booking-grid">
        <article class="te-booking-card te-booking-card--wide">
            <h2 class="te-booking-card__header">Voos</h2>
            <% if (viagens.isEmpty()) { %>
            <p class="te-booking-card__empty">Sem voos associados.</p>
            <% } else { %>
            <% if (!voosIda.isEmpty()) { %>
            <div class="te-flight-timeline">
                <div class="te-flight-timeline__head">
                    <h3>Voo de ida</h3>
                    <span class="te-flight-timeline__stops"><%= escapeHtml(flightStopsLabel(voosIda)) %></span>
                </div>
                <% for (Viagens v : voosIda) { %>
                <%= renderFlightTimelineItem(v, timeFormatter, currencyFormat) %>
                <% } %>
            </div>
            <% } %>
            <% if (!voosRegresso.isEmpty()) { %>
            <div class="te-flight-timeline">
                <div class="te-flight-timeline__head">
                    <h3>Voo de regresso</h3>
                    <span class="te-flight-timeline__stops"><%= escapeHtml(flightStopsLabel(voosRegresso)) %></span>
                </div>
                <% for (Viagens v : voosRegresso) { %>
                <%= renderFlightTimelineItem(v, timeFormatter, currencyFormat) %>
                <% } %>
            </div>
            <% } %>
            <% if (!voosOutros.isEmpty()) { %>
            <div class="te-flight-timeline">
                <div class="te-flight-timeline__head"><h3>Voos da reserva</h3></div>
                <% for (Viagens v : voosOutros) { %>
                <%= renderFlightTimelineItem(v, timeFormatter, currencyFormat) %>
                <% } %>
            </div>
            <% } %>
            <% } %>
        </article>

        <article class="te-booking-card">
            <h2 class="te-booking-card__header">Alojamento</h2>
            <% if (alojamentos.isEmpty()) { %>
            <p class="te-booking-card__empty">Sem alojamento associado.</p>
            <% } else { %>
            <% for (Alojamento a : alojamentos) { %>
            <div class="te-hotel-block">
                <div class="te-hotel-block__icon" aria-hidden="true">🏨</div>
                <div>
                    <p class="te-hotel-block__name"><%= escapeHtml(a.getNome()) %></p>
                    <p class="te-hotel-block__cat"><%= escapeHtml(formatHotelCategory(a)) %></p>
                    <% if (hasText(a.getMorada())) { %><p class="te-hotel-block__zone"><%= escapeHtml(a.getMorada()) %></p><% } %>
                    <% if (a.getPreco() > 0) { %><p class="te-hotel-block__price"><%= escapeHtml(currencyFormat.format(a.getPreco())) %> <small>estimado</small></p><% } %>
                </div>
            </div>
            <% } %>
            <% } %>
        </article>

        <article class="te-booking-card">
            <h2 class="te-booking-card__header">Transporte</h2>
            <% if (transportes.isEmpty()) { %>
            <p class="te-booking-card__empty">Transporte ainda não definido.</p>
            <% } else { %>
            <% for (Transporte t : transportes) { %>
            <dl class="te-booking-kv te-booking-kv--compact">
                <% if (hasText(t.getTipo())) { %><div><dt class="te-booking-label">Tipo</dt><dd class="te-booking-value"><%= escapeHtml(t.getTipo()) %></dd></div><% } %>
                <% if (hasText(t.getOrigem())) { %><div><dt class="te-booking-label">Origem</dt><dd class="te-booking-value"><%= escapeHtml(t.getOrigem()) %></dd></div><% } %>
                <% if (hasText(t.getDestino())) { %><div><dt class="te-booking-label">Destino</dt><dd class="te-booking-value"><%= escapeHtml(t.getDestino()) %></dd></div><% } %>
                <% if (t.getPreco() > 0) { %><div><dt class="te-booking-label">Preço estimado</dt><dd class="te-booking-value"><%= escapeHtml(currencyFormat.format(t.getPreco())) %></dd></div><% } %>
            </dl>
            <% } %>
            <% } %>
        </article>

        <article class="te-booking-card">
            <h2 class="te-booking-card__header">Atividades</h2>
            <% if (atividadesLista.isEmpty()) { %>
            <p class="te-booking-card__empty">Ainda não existem atividades sugeridas.</p>
            <% } else { %>
            <div class="te-activity-chips">
                <% for (String atividade : atividadesLista) { %>
                <span class="te-activity-chip"><%= escapeHtml(atividade) %></span>
                <% } %>
            </div>
            <% } %>
        </article>

        <article class="te-booking-card">
            <h2 class="te-booking-card__header">Pagamento</h2>
            <% if (pagamentoPago) { %>
            <p class="te-booking-card__status te-booking-card__status--ok">Pagamento concluído</p>
            <dl class="te-booking-kv te-booking-kv--compact">
                <div><dt class="te-booking-label">Estado</dt><dd class="te-booking-value"><%= escapeHtml(pagEstado) %></dd></div>
                <div><dt class="te-booking-label">Total</dt><dd class="te-booking-value"><%= escapeHtml(hasText(pagValor) ? pagValor : total) %></dd></div>
                <% if (pagMetodoDisplay != null) { %>
                <div><dt class="te-booking-label">Método</dt><dd class="te-booking-value"><%= escapeHtml(pagMetodoDisplay) %></dd></div>
                <% } %>
                <% if (hasText(pagReferencia)) { %>
                <div><dt class="te-booking-label">Referência</dt><dd class="te-booking-value"><%= escapeHtml(pagReferencia) %></dd></div>
                <% } %>
                <% if (hasText(pagData)) { %>
                <div><dt class="te-booking-label">Data</dt><dd class="te-booking-value"><%= escapeHtml(pagData) %></dd></div>
                <% } %>
            </dl>
            <% } else { %>
            <p class="te-booking-card__status">Pagamento pendente</p>
            <dl class="te-booking-kv te-booking-kv--compact">
                <div><dt class="te-booking-label">Estado</dt><dd class="te-booking-value">Pendente</dd></div>
                <div><dt class="te-booking-label">Total</dt><dd class="te-booking-value te-booking-value--price"><%= escapeHtml(total) %></dd></div>
            </dl>
            <a class="btn btn-primary te-booking-card__cta" href="<%= ctx %>/index.jsp?page=pay-reservation&amp;idReserva=<%= reservation.getIdReserva() %>">Pagar reserva</a>
            <% } %>
        </article>

        <article class="te-booking-card te-booking-card--wide">
            <h2 class="te-booking-card__header">Apoio</h2>
            <% if (suporte == null) { %>
            <form class="te-support-form" method="post" action="<%= ctx %>/suporte">
                <input type="hidden" name="action" value="contact">
                <input type="hidden" name="idReserva" value="<%= reservation.getIdReserva() %>">
                <p class="te-booking-value">Tens alguma questão sobre esta reserva?</p>
                <textarea class="input" name="mensagem" rows="3" required placeholder="Escreve a tua mensagem"></textarea>
                <button type="submit" class="btn btn-secondary">Contactar apoio</button>
            </form>
            <% } else { %>
            <p class="te-booking-value te-booking-value--strong"><%= escapeHtml(suporte.getTitulo()) %></p>
            <p class="te-booking-value"><%= escapeHtml(suporte.getMensagem()) %></p>
            <% if (suporteRespondido) { %>
            <div class="te-support-reply">
                <span class="te-booking-label">Resposta da equipa</span>
                <p class="te-booking-value"><%= escapeHtml(suporte.getResposta()) %></p>
            </div>
            <% } else { %>
            <p class="te-booking-card__muted">A aguardar resposta da equipa</p>
            <% } %>
            <% } %>
        </article>
    </div>

    <div class="te-page-back">
        <a class="btn btn-ghost" href="<%= ctx %>/index.jsp?page=my-reservations">Voltar às reservas</a>
    </div>
    <% } %>
</div>
