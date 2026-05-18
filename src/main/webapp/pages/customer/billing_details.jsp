<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Connection.Classes.Cliente" %>
<%@ page import="Connection.CRUD.ClienteCRUD" %>
<%!
private String escapeHtml(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
}
%>
<%
Object userIdObj = session.getAttribute("userId");
if (userIdObj == null || !Boolean.TRUE.equals(session.getAttribute("auth")) || !"cliente".equals(session.getAttribute("userType"))) {
    response.sendRedirect(request.getContextPath() + "/index.jsp?page=login");
    return;
}
int idCliente = Integer.parseInt(userIdObj.toString());
Cliente cliente = new ClienteCRUD().findById(idCliente);
String ctx = request.getContextPath();
String idReserva = request.getParameter("idReserva");
String returnTo = request.getParameter("returnTo");
String error = request.getParameter("error");
String moradaVal = cliente != null && cliente.getMorada() != null ? cliente.getMorada() : "";
String nifVal = cliente != null && cliente.getNIF() > 0 ? String.valueOf(cliente.getNIF()) : "";
String dataVal = cliente != null && cliente.getDataNasc() != null ? cliente.getDataNasc().toString() : "";
%>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Faturação" />
        <jsp:param name="heading" value="Completar dados de faturação" />
        <jsp:param name="description" value="Para efeitos fiscais e emissão da reserva, completa os teus dados antes de continuar." />
    </jsp:include>

    <% if ("invalid-data".equals(error)) { %>
    <div class="surface-block"><p class="text-muted">Preenche todos os campos corretamente.</p></div>
    <% } else if ("save-failed".equals(error)) { %>
    <div class="surface-block"><p class="text-muted">Não foi possível guardar os dados. Tenta novamente.</p></div>
    <% } %>

    <div class="surface-block surface-block-lg customer-action-panel">
        <form class="flow" method="post" action="<%= ctx %>/cliente-billing">
            <input type="hidden" name="returnTo" value="<%= escapeHtml(returnTo != null ? returnTo : "") %>">
            <% if (idReserva != null && !idReserva.isEmpty()) { %>
            <input type="hidden" name="idReserva" value="<%= escapeHtml(idReserva) %>">
            <% } %>
            <div class="flow" style="gap: 1rem;">
                <label class="flow" style="gap: 0.35rem;">
                    <span>Morada</span>
                    <input class="input" type="text" name="morada" required value="<%= escapeHtml(moradaVal) %>">
                </label>
                <label class="flow" style="gap: 0.35rem;">
                    <span>NIF</span>
                    <input class="input" type="number" name="nif" required min="1" value="<%= escapeHtml(nifVal) %>">
                </label>
                <label class="flow" style="gap: 0.35rem;">
                    <span>Data de nascimento</span>
                    <input class="input" type="date" name="data_nascimento" required value="<%= escapeHtml(dataVal) %>">
                </label>
            </div>
            <div class="actions-row">
                <button type="submit" class="btn btn-primary">Guardar e continuar</button>
                <% if (idReserva != null && !idReserva.isEmpty()) { %>
                <a class="btn btn-secondary" href="<%= ctx %>/index.jsp?page=reservation-details&amp;idReserva=<%= escapeHtml(idReserva) %>">Cancelar</a>
                <% } else { %>
                <a class="btn btn-secondary" href="<%= ctx %>/index.jsp?page=profile">Cancelar</a>
                <% } %>
            </div>
        </form>
    </div>
</div>
