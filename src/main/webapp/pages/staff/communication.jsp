<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.time.format.DateTimeFormatter,Connection.Classes.Comunicacao,Connection.Classes.Cliente,Connection.CRUD.ComunicacaoCRUD,Connection.CRUD.ClienteCRUD" %>
<%
ComunicacaoCRUD comunicacaoCRUD = new ComunicacaoCRUD();
ClienteCRUD clienteCRUD = new ClienteCRUD();
List<Comunicacao> pedidos = comunicacaoCRUD.findSupportTickets();
String selC = request.getParameter("selectedComunicacao");
Comunicacao selCom = null;
if (selC != null && !selC.trim().isEmpty()) {
    try { selCom = comunicacaoCRUD.findById(Integer.parseInt(selC.trim())); } catch (NumberFormatException ignored) {}
}
String success = request.getParameter("success");
String error = request.getParameter("error");
String commBase = request.getContextPath() + "/index.jsp?page=staff-communication";
DateTimeFormatter dfPt = DateTimeFormatter.ofPattern("dd/MM/yyyy").withLocale(java.util.Locale.forLanguageTag("pt-PT"));
%>

<div id="staffCommRoot" class="staff-shell staff-offers-page" data-comm-base="<%= commBase %>">
<div class="flow">
    <% if ("support-answered".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Resposta enviada com sucesso.</div></div>
    <% } %>
    <% if ("invalid-data".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Dados inválidos.</div></div>
    <% } %>

    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Apoio" />
        <jsp:param name="heading" value="Pedidos de apoio" />
        <jsp:param name="description" value="Mensagens enviadas pelos clientes a partir das reservas." />
    </jsp:include>

    <div class="surface-block surface-block-lg staff-action-panel">
        <% if (pedidos.isEmpty()) { %>
        <p class="text-muted">Ainda não existem pedidos de apoio.</p>
        <% } else { %>
        <div class="staff-offers-table-wrap">
            <table class="staff-offers-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Título</th>
                        <th>Cliente</th>
                        <th>Reserva</th>
                        <th>Data</th>
                        <th>Estado</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Comunicacao co : pedidos) {
                        Cliente cl = co.getIdCliente() > 0 ? clienteCRUD.findById(co.getIdCliente()) : null;
                        String clNome = cl != null && cl.getNome() != null ? cl.getNome() : "—";
                        String clEmail = cl != null && cl.getEmail() != null ? cl.getEmail() : "";
                        String d = co.getDataComunicacao() != null ? co.getDataComunicacao().format(dfPt) : "—";
                    %>
                    <tr>
                        <td><%= co.getIdComunicacao() %></td>
                        <td><strong><%= co.getTitulo() != null ? co.getTitulo() : "" %></strong></td>
                        <td><%= clNome %><% if (!clEmail.isEmpty()) { %><br><span class="text-muted" style="font-size:0.85rem;"><%= clEmail %></span><% } %></td>
                        <td><%= co.getIdReserva() > 0 ? "#" + co.getIdReserva() : "—" %></td>
                        <td><%= d %></td>
                        <td><%= co.getEstado() != null ? co.getEstado() : "" %></td>
                        <td><a class="btn btn-secondary" style="padding:0.35rem 0.65rem;font-size:0.85rem;" href="<%= commBase %>&amp;selectedComunicacao=<%= co.getIdComunicacao() %>">Responder</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>

<% if (selCom != null) { %>
<div id="staffCommBackdrop" class="staff-drawer-backdrop is-open" aria-hidden="false"></div>
<div id="staffCommDrawer" class="staff-drawer is-open" aria-hidden="false">
    <div class="staff-drawer__header">
        <h2 class="staff-drawer__title">Pedido #<%= selCom.getIdComunicacao() %></h2>
        <button type="button" class="staff-drawer__close" id="staffCommClose" aria-label="Fechar">&times;</button>
    </div>
    <div class="staff-drawer__body flow">
        <% Cliente clSel = selCom.getIdCliente() > 0 ? clienteCRUD.findById(selCom.getIdCliente()) : null; %>
        <p><strong>Cliente:</strong> <%= clSel != null ? clSel.getNome() : "—" %> <% if (clSel != null && clSel.getEmail() != null) { %>(<%= clSel.getEmail() %>)<% } %></p>
        <% if (selCom.getIdReserva() > 0) { %><p><strong>Reserva:</strong> #<%= selCom.getIdReserva() %></p><% } %>
        <p><strong>Mensagem:</strong></p>
        <p class="text-muted"><%= selCom.getMensagem() != null ? selCom.getMensagem() : "" %></p>
        <% if (selCom.getResposta() != null && !selCom.getResposta().trim().isEmpty()) { %>
        <div class="surface-block">
            <span class="section-title__eyebrow">Respondido</span>
            <p class="text-muted"><%= selCom.getResposta() %></p>
        </div>
        <% } else { %>
        <form class="flow" method="post" action="${pageContext.request.contextPath}/suporte">
            <input type="hidden" name="action" value="answer">
            <input type="hidden" name="idComunicacao" value="<%= selCom.getIdComunicacao() %>">
            <label for="resposta">Resposta</label>
            <textarea id="resposta" name="resposta" rows="5" required></textarea>
            <button type="submit" class="btn btn-primary">Responder</button>
        </form>
        <% } %>
    </div>
</div>
<script>
(function() {
  var base = document.getElementById('staffCommRoot').getAttribute('data-comm-base') || '';
  function closeAll() { window.location.href = base; }
  document.getElementById('staffCommBackdrop')?.addEventListener('click', function(ev) { if (ev.target.id === 'staffCommBackdrop') closeAll(); });
  document.getElementById('staffCommClose')?.addEventListener('click', closeAll);
  document.addEventListener('keydown', function(ev) { if (ev.key === 'Escape') closeAll(); });
})();
</script>
<% } %>
</div>
