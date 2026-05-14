<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.time.format.DateTimeFormatter,Connection.Classes.Comunicacao,Connection.Classes.Cliente,Connection.CRUD.ComunicacaoCRUD,Connection.CRUD.ClienteCRUD" %>
<%!
private static String escAttr(String s) {
    if (s == null) {
        return "";
    }
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
}
%>
<%
ComunicacaoCRUD comunicacaoCRUD = new ComunicacaoCRUD();
ClienteCRUD clienteCRUD = new ClienteCRUD();
List<Comunicacao> comunicacoes = comunicacaoCRUD.findAll();
List<Cliente> clientes = clienteCRUD.findAll();
String selC = request.getParameter("selectedComunicacao");
Comunicacao selCom = null;
if (selC != null && !selC.trim().isEmpty()) {
    try {
        selCom = comunicacaoCRUD.findById(Integer.parseInt(selC.trim()));
    } catch (NumberFormatException ignored) {
    }
}
String success = request.getParameter("success");
String error = request.getParameter("error");
String commBase = request.getContextPath() + "/index.jsp?page=staff-communication";
DateTimeFormatter dfIso = DateTimeFormatter.ISO_LOCAL_DATE;
DateTimeFormatter dfPt = DateTimeFormatter.ofPattern("dd/MM/yyyy").withLocale(java.util.Locale.forLanguageTag("pt-PT"));
boolean selInvalid = selC != null && !selC.trim().isEmpty() && selCom == null;
%>

<div id="staffCommRoot" class="staff-shell staff-offers-page" data-comm-base="<%= commBase %>">

<div class="flow">
    <% if ("communication-created".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Comunicação criada com sucesso.</div></div>
    <% } %>
    <% if ("communication-updated".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Comunicação atualizada com sucesso.</div></div>
    <% } %>
    <% if ("communication-deleted".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Comunicação eliminada com sucesso.</div></div>
    <% } %>
    <% if ("invalid-data".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Dados inválidos.</div></div>
    <% } %>
    <% if (selInvalid) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Comunicação não encontrada.</div></div>
    <% } %>

    <div class="staff-offers-page-header">
        <div class="section-title">
            <span class="section-title__eyebrow">Comunicação</span>
            <h1 class="section-title__heading">Gestão de comunicação</h1>
            <p class="section-title__description">Registos na tabela COMUNICACAO, com cliente associado opcional.</p>
        </div>
        <div class="actions-row" style="flex-shrink: 0;">
            <button type="button" class="btn btn-primary" id="staffCommBtnNovo">+ Nova comunicação</button>
        </div>
    </div>

    <div class="surface-block surface-block-lg staff-action-panel">
        <% if (comunicacoes == null || comunicacoes.isEmpty()) { %>
        <p class="text-muted">Ainda não existem comunicações registadas.</p>
        <% } else { %>
        <div class="staff-offers-table-wrap">
            <table class="staff-offers-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Título</th>
                        <th>Canal</th>
                        <th>Segmento</th>
                        <th>Data</th>
                        <th>Estado</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Comunicacao co : comunicacoes) {
                        String d = co.getDataComunicacao() != null ? co.getDataComunicacao().format(dfPt) : "—";
                    %>
                    <tr>
                        <td><%= co.getIdComunicacao() %></td>
                        <td><strong><%= co.getTitulo() != null ? co.getTitulo() : "" %></strong></td>
                        <td><%= co.getCanal() != null ? co.getCanal() : "" %></td>
                        <td><%= co.getSegmento() != null ? co.getSegmento() : "" %></td>
                        <td><%= d %></td>
                        <td><%= co.getEstado() != null ? co.getEstado() : "" %></td>
                        <td><a class="btn btn-secondary" style="padding: 0.35rem 0.65rem; font-size: 0.85rem;" href="<%= commBase %>&amp;selectedComunicacao=<%= co.getIdComunicacao() %>">Gerir</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>

<div id="staffCommBackdrop" class="staff-drawer-backdrop" aria-hidden="true"></div>
<div id="staffCommDrawerCreate" class="staff-drawer" aria-hidden="true">
    <div class="staff-drawer__header">
        <h2 class="staff-drawer__title">Nova comunicação</h2>
        <button type="button" class="staff-drawer__close" id="staffCommCloseCreate" aria-label="Fechar">&times;</button>
    </div>
    <div class="staff-drawer__body flow">
        <form class="flow" action="${pageContext.request.contextPath}/staff-communication" method="post">
            <input type="hidden" name="action" value="create-communication">
            <div>
                <label for="commTituloC">Título</label>
                <input type="text" id="commTituloC" name="titulo" required>
            </div>
            <div>
                <label for="commCanalC">Canal</label>
                <input type="text" id="commCanalC" name="canal" required>
            </div>
            <div>
                <label for="commSegC">Segmento</label>
                <input type="text" id="commSegC" name="segmento">
            </div>
            <div>
                <label for="commDataC">Data da comunicação</label>
                <input type="date" id="commDataC" name="data_comunicacao">
            </div>
            <div>
                <label for="commEstC">Estado</label>
                <input type="text" id="commEstC" name="estado" required>
            </div>
            <div>
                <label for="commMsgC">Mensagem</label>
                <textarea id="commMsgC" name="mensagem" rows="3"></textarea>
            </div>
            <div>
                <label for="commCliC">Cliente (opcional)</label>
                <select id="commCliC" name="idCliente">
                    <option value="0">—</option>
                    <% for (Cliente cl : clientes) { %>
                    <option value="<%= cl.getIdCliente() %>"><%= cl.getNome() != null ? cl.getNome() : ("#" + cl.getIdCliente()) %></option>
                    <% } %>
                </select>
            </div>
            <div class="actions-row" style="margin-top: 1rem;">
                <button class="btn btn-primary" type="submit">Criar comunicação</button>
                <button type="button" class="btn btn-secondary" id="staffCommCancelCreate">Cancelar</button>
            </div>
        </form>
    </div>
</div>

<% if (selCom != null) { %>
<div id="staffCommDrawerEdit" class="staff-drawer" aria-hidden="true">
    <div class="staff-drawer__header">
        <h2 class="staff-drawer__title">Comunicação #<%= selCom.getIdComunicacao() %></h2>
        <button type="button" class="staff-drawer__close" id="staffCommCloseEdit" aria-label="Fechar">&times;</button>
    </div>
    <div class="staff-drawer__body flow">
        <form class="flow" action="${pageContext.request.contextPath}/staff-communication" method="post">
            <input type="hidden" name="action" value="update-communication">
            <input type="hidden" name="idComunicacao" value="<%= selCom.getIdComunicacao() %>">
            <div>
                <label for="commTituloE">Título</label>
                <input type="text" id="commTituloE" name="titulo" value="<%= escAttr(selCom.getTitulo()) %>" required>
            </div>
            <div>
                <label for="commCanalE">Canal</label>
                <input type="text" id="commCanalE" name="canal" value="<%= escAttr(selCom.getCanal()) %>" required>
            </div>
            <div>
                <label for="commSegE">Segmento</label>
                <input type="text" id="commSegE" name="segmento" value="<%= escAttr(selCom.getSegmento()) %>">
            </div>
            <div>
                <label for="commDataE">Data da comunicação</label>
                <input type="date" id="commDataE" name="data_comunicacao" value="<%= selCom.getDataComunicacao() != null ? selCom.getDataComunicacao().format(dfIso) : "" %>">
            </div>
            <div>
                <label for="commEstE">Estado</label>
                <input type="text" id="commEstE" name="estado" value="<%= escAttr(selCom.getEstado()) %>" required>
            </div>
            <div>
                <label for="commMsgE">Mensagem</label>
                <textarea id="commMsgE" name="mensagem" rows="3"><%= escAttr(selCom.getMensagem()) %></textarea>
            </div>
            <div>
                <label for="commCliE">Cliente (opcional)</label>
                <select id="commCliE" name="idCliente">
                    <option value="0"<%= selCom.getIdCliente() <= 0 ? " selected" : "" %>>—</option>
                    <% for (Cliente cl : clientes) { %>
                    <option value="<%= cl.getIdCliente() %>"<%= cl.getIdCliente() == selCom.getIdCliente() ? " selected" : "" %>><%= cl.getNome() != null ? cl.getNome() : ("#" + cl.getIdCliente()) %></option>
                    <% } %>
                </select>
            </div>
            <div class="actions-row" style="margin-top: 1rem;">
                <button class="btn btn-primary" type="submit">Guardar alterações</button>
                <button type="button" class="btn btn-secondary" id="staffCommCancelEdit">Cancelar</button>
            </div>
        </form>
        <form action="${pageContext.request.contextPath}/staff-communication" method="post" style="margin-top: 0.75rem;" onsubmit="return confirm('Eliminar esta comunicação?');">
            <input type="hidden" name="action" value="delete-communication">
            <input type="hidden" name="idComunicacao" value="<%= selCom.getIdComunicacao() %>">
            <button class="btn btn-secondary" type="submit" style="border-color: #b42318; color: #b42318;">Eliminar</button>
        </form>
    </div>
</div>
<% } %>

</div>

<script>
(function() {
  var root = document.getElementById('staffCommRoot');
  if (!root) return;
  var base = root.getAttribute('data-comm-base') || '';
  var backdrop = document.getElementById('staffCommBackdrop');
  var drawerCreate = document.getElementById('staffCommDrawerCreate');
  var drawerEdit = document.getElementById('staffCommDrawerEdit');
  var btnNovo = document.getElementById('staffCommBtnNovo');
  var btnCloseC = document.getElementById('staffCommCloseCreate');
  var btnCancelC = document.getElementById('staffCommCancelCreate');
  var btnCloseE = document.getElementById('staffCommCloseEdit');
  var btnCancelE = document.getElementById('staffCommCancelEdit');
  function lockScroll(on) { document.body.style.overflow = on ? 'hidden' : ''; }
  function openCreate() {
    if (!backdrop || !drawerCreate) return;
    if (drawerEdit && drawerEdit.classList.contains('is-open')) {
      window.location.href = base + '&openCreate=1';
      return;
    }
    backdrop.classList.add('is-open');
    drawerCreate.classList.add('is-open');
    backdrop.setAttribute('aria-hidden', 'false');
    drawerCreate.setAttribute('aria-hidden', 'false');
    lockScroll(true);
  }
  function closeCreate() {
    if (!backdrop || !drawerCreate) return;
    drawerCreate.classList.remove('is-open');
    drawerCreate.setAttribute('aria-hidden', 'true');
    if (!drawerEdit || !drawerEdit.classList.contains('is-open')) {
      backdrop.classList.remove('is-open');
      backdrop.setAttribute('aria-hidden', 'true');
      lockScroll(false);
    }
  }
  function openEdit() {
    if (!backdrop || !drawerEdit) return;
    backdrop.classList.add('is-open');
    drawerEdit.classList.add('is-open');
    backdrop.setAttribute('aria-hidden', 'false');
    drawerEdit.setAttribute('aria-hidden', 'false');
    lockScroll(true);
  }
  function closeEditNav() { window.location.href = base; }
  if (btnNovo) btnNovo.addEventListener('click', openCreate);
  if (btnCloseC) btnCloseC.addEventListener('click', function(ev) { ev.preventDefault(); ev.stopPropagation(); closeCreate(); });
  if (btnCancelC) btnCancelC.addEventListener('click', function(ev) { ev.preventDefault(); ev.stopPropagation(); closeCreate(); });
  if (backdrop) {
    backdrop.addEventListener('click', function(ev) {
      if (ev.target !== backdrop) return;
      if (drawerCreate && drawerCreate.classList.contains('is-open')) { closeCreate(); return; }
      if (drawerEdit && drawerEdit.classList.contains('is-open')) closeEditNav();
    });
  }
  if (btnCloseE) btnCloseE.addEventListener('click', function(ev) { ev.preventDefault(); ev.stopPropagation(); closeEditNav(); });
  if (btnCancelE) btnCancelE.addEventListener('click', function(ev) { ev.preventDefault(); ev.stopPropagation(); closeEditNav(); });
  var params = new URLSearchParams(window.location.search);
  if (params.get('openCreate') === '1') {
    if (window.history && window.history.replaceState) window.history.replaceState({}, '', base);
    openCreate();
  } else if (drawerEdit && params.get('selectedComunicacao')) {
    openEdit();
  }
  document.addEventListener('keydown', function(ev) {
    if (ev.key === 'Escape') {
      if (drawerCreate && drawerCreate.classList.contains('is-open')) closeCreate();
      else if (drawerEdit && drawerEdit.classList.contains('is-open')) closeEditNav();
    }
  });
})();
</script>
