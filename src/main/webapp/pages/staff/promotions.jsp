<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.time.format.DateTimeFormatter,Connection.Classes.Promocao,Connection.Classes.Pacote,Connection.CRUD.PromocaoCRUD,Connection.CRUD.PacoteCRUD" %>
<%!
private static String escAttr(String s) {
    if (s == null) {
        return "";
    }
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
}
%>
<%
PromocaoCRUD promocaoCRUD = new PromocaoCRUD();
PacoteCRUD pacoteCRUD = new PacoteCRUD();
List<Promocao> promocoes = promocaoCRUD.findAll();
List<Pacote> pacotes = pacoteCRUD.findPublicOfertas(100);
if (pacotes.isEmpty()) {
    pacotes = pacoteCRUD.findPublicPacotes(100);
}
java.text.DecimalFormatSymbols symPr = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
symPr.setDecimalSeparator(',');
symPr.setGroupingSeparator(' ');
java.text.DecimalFormat dfPromo = new java.text.DecimalFormat("#,##0.00", symPr);
String selP = request.getParameter("selectedPromocao");
Promocao selPromo = null;
if (selP != null && !selP.trim().isEmpty()) {
    try {
        selPromo = promocaoCRUD.findById(Integer.parseInt(selP.trim()));
    } catch (NumberFormatException ignored) {
    }
}
String success = request.getParameter("success");
String error = request.getParameter("error");
String promoBase = request.getContextPath() + "/index.jsp?page=staff-promotions";
DateTimeFormatter dfIso = DateTimeFormatter.ISO_LOCAL_DATE;
DateTimeFormatter dfPt = DateTimeFormatter.ofPattern("dd/MM/yyyy").withLocale(java.util.Locale.forLanguageTag("pt-PT"));
boolean selInvalid = selP != null && !selP.trim().isEmpty() && selPromo == null;
%>

<div id="staffPromoRoot" class="staff-shell staff-offers-page" data-promo-base="<%= promoBase %>">

<div class="flow">
    <% if ("promotion-created".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Promoção criada com sucesso.</div></div>
    <% } %>
    <% if ("promotion-updated".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Promoção atualizada com sucesso.</div></div>
    <% } %>
    <% if ("promotion-deleted".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Promoção eliminada com sucesso.</div></div>
    <% } %>
    <% if ("invalid-data".equals(error) || "invalid-action".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Pedido inválido. Tenta novamente.</div></div>
    <% } %>
    <% if ("missing-pacote".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Seleciona uma oferta ou pacote alvo.</div></div>
    <% } %>
    <% if ("invalid-pacote".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">O pacote selecionado não é válido para promoção pública.</div></div>
    <% } %>
    <% if ("missing-dates".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Indica a data de início e de fim da promoção.</div></div>
    <% } %>
    <% if ("invalid-dates".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">A data de fim não pode ser anterior à data de início.</div></div>
    <% } %>
    <% if ("invalid-discount".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">O desconto deve ser entre 1% e 99%.</div></div>
    <% } %>
    <% if ("save-failed".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Não foi possível guardar a promoção. Verifica os dados e tenta novamente.</div></div>
    <% } %>
    <% if (selInvalid) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Promoção não encontrada.</div></div>
    <% } %>

    <div class="staff-offers-page-header">
        <div class="section-title">
            <span class="section-title__eyebrow">Promoções</span>
            <h1 class="section-title__heading">Gestão de promoções</h1>
            <p class="section-title__description">Campanhas e promoções registadas na base PROMOCAO, com ligação opcional a pacotes.</p>
        </div>
        <div class="actions-row" style="flex-shrink: 0;">
            <button type="button" class="btn btn-primary" id="staffPromoBtnNovo">+ Nova promoção</button>
        </div>
    </div>

    <div class="surface-block surface-block-lg staff-action-panel">
        <% if (promocoes == null || promocoes.isEmpty()) { %>
        <p class="text-muted">Ainda não existem promoções registadas.</p>
        <% } else { %>
        <div class="staff-offers-table-wrap">
            <table class="staff-offers-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Título</th>
                        <th>Destino</th>
                        <th>Início</th>
                        <th>Fim</th>
                        <th>Estado</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Promocao pr : promocoes) {
                        String pi = pr.getPeriodoInicio() != null ? pr.getPeriodoInicio().format(dfPt) : "—";
                        String pf = pr.getPeriodoFim() != null ? pr.getPeriodoFim().format(dfPt) : "—";
                    %>
                    <tr>
                        <td><%= pr.getIdPromocao() %></td>
                        <td><strong><%= pr.getTitulo() != null ? pr.getTitulo() : "" %></strong></td>
                        <td><%= pr.getDestino() != null ? pr.getDestino() : "" %></td>
                        <td><%= pi %></td>
                        <td><%= pf %></td>
                        <td><%= pr.getEstado() != null ? pr.getEstado() : "" %></td>
                        <td><a class="btn btn-secondary" style="padding: 0.35rem 0.65rem; font-size: 0.85rem;" href="<%= promoBase %>&amp;selectedPromocao=<%= pr.getIdPromocao() %>">Gerir</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>

<div id="staffPromoBackdrop" class="staff-drawer-backdrop" aria-hidden="true"></div>
<div id="staffPromoDrawerCreate" class="staff-drawer" aria-hidden="true">
    <div class="staff-drawer__header">
        <h2 class="staff-drawer__title">Nova promoção</h2>
        <button type="button" class="staff-drawer__close" id="staffPromoCloseCreate" aria-label="Fechar">&times;</button>
    </div>
    <div class="staff-drawer__body flow">
        <form class="flow" id="staffPromoCreateForm" action="${pageContext.request.contextPath}/staff-promotions" method="post">
            <input type="hidden" name="action" value="create-promotion">
            <div>
                <label for="promoPacC">Oferta / pacote alvo</label>
                <select id="promoPacC" name="idPacote" required>
                    <option value="">— Seleciona uma oferta —</option>
                    <% for (Pacote pk : pacotes) {
                        String destPreview = pk.getNome() != null ? pk.getNome() : ("Oferta #" + pk.getIdPacote());
                    %>
                    <option value="<%= pk.getIdPacote() %>"
                        data-nome="<%= escAttr(pk.getNome()) %>"
                        data-destino="<%= escAttr(destPreview) %>"
                        data-preco="<%= pk.getPrecoBase() %>"
                        data-imagem="<%= escAttr(pk.getImagemUrl() != null ? pk.getImagemUrl() : "") %>"><%= pk.getNome() != null ? pk.getNome() : ("#" + pk.getIdPacote()) %> — <%= dfPromo.format(pk.getPrecoBase()) %> €</option>
                    <% } %>
                </select>
            </div>
            <div id="promoPreviewC" class="staff-promo-preview" hidden>
                <p><strong id="promoPreviewNomeC"></strong></p>
                <p class="text-muted" id="promoPreviewDestC"></p>
                <p>Preço original: <strong id="promoPreviewPrecoC"></strong></p>
                <p id="promoPreviewFinalC" class="staff-promo-preview__final"></p>
            </div>
            <div>
                <label for="promoDescC">Desconto (%)</label>
                <input type="number" id="promoDescC" name="desconto_percent" min="1" max="99" step="1" value="10" required>
            </div>
            <div>
                <label for="promoTituloC">Título</label>
                <input type="text" id="promoTituloC" name="titulo" placeholder="Preenchido automaticamente ao escolher o pacote">
            </div>
            <div>
                <label for="promoDestC">Destino</label>
                <input type="text" id="promoDestC" name="destino" placeholder="Preenchido automaticamente ao escolher o pacote">
            </div>
            <div>
                <label for="promoPiC">Início</label>
                <input type="date" id="promoPiC" name="periodo_inicio" required>
            </div>
            <div>
                <label for="promoPfC">Fim</label>
                <input type="date" id="promoPfC" name="periodo_fim" required>
            </div>
            <div>
                <label for="promoCondC">Condição</label>
                <textarea id="promoCondC" name="condicao" rows="2"></textarea>
            </div>
            <div>
                <label for="promoEstC">Estado</label>
                <input type="text" id="promoEstC" name="estado" value="Ativa" required>
            </div>
            <div class="actions-row" style="margin-top: 1rem;">
                <button class="btn btn-primary" type="submit">Criar promoção</button>
                <button type="button" class="btn btn-secondary" id="staffPromoCancelCreate">Cancelar</button>
            </div>
        </form>
    </div>
</div>

<% if (selPromo != null) { %>
<div id="staffPromoDrawerEdit" class="staff-drawer" aria-hidden="true">
    <div class="staff-drawer__header">
        <h2 class="staff-drawer__title">Promoção #<%= selPromo.getIdPromocao() %></h2>
        <button type="button" class="staff-drawer__close" id="staffPromoCloseEdit" aria-label="Fechar">&times;</button>
    </div>
    <div class="staff-drawer__body flow">
        <form class="flow" action="${pageContext.request.contextPath}/staff-promotions" method="post">
            <input type="hidden" name="action" value="update-promotion">
            <input type="hidden" name="idPromocao" value="<%= selPromo.getIdPromocao() %>">
            <div>
                <label for="promoTituloE">Título</label>
                <input type="text" id="promoTituloE" name="titulo" value="<%= escAttr(selPromo.getTitulo()) %>" required>
            </div>
            <div>
                <label for="promoDestE">Destino</label>
                <input type="text" id="promoDestE" name="destino" value="<%= escAttr(selPromo.getDestino()) %>" required>
            </div>
            <div>
                <label for="promoPiE">Início</label>
                <input type="date" id="promoPiE" name="periodo_inicio" value="<%= selPromo.getPeriodoInicio() != null ? selPromo.getPeriodoInicio().format(dfIso) : "" %>">
            </div>
            <div>
                <label for="promoPfE">Fim</label>
                <input type="date" id="promoPfE" name="periodo_fim" value="<%= selPromo.getPeriodoFim() != null ? selPromo.getPeriodoFim().format(dfIso) : "" %>">
            </div>
            <div>
                <label for="promoCondE">Condição</label>
                <textarea id="promoCondE" name="condicao" rows="2"><%= escAttr(selPromo.getCondicao()) %></textarea>
            </div>
            <div>
                <label for="promoEstE">Estado</label>
                <input type="text" id="promoEstE" name="estado" value="<%= escAttr(selPromo.getEstado()) %>" required>
            </div>
            <div>
                <label for="promoPacE">Pacote (opcional)</label>
                <select id="promoPacE" name="idPacote">
                    <option value="0"<%= selPromo.getIdPacote() <= 0 ? " selected" : "" %>>—</option>
                    <% for (Pacote pk : pacotes) { %>
                    <option value="<%= pk.getIdPacote() %>"<%= pk.getIdPacote() == selPromo.getIdPacote() ? " selected" : "" %>><%= pk.getNome() != null ? pk.getNome() : ("#" + pk.getIdPacote()) %></option>
                    <% } %>
                </select>
            </div>
            <div class="actions-row" style="margin-top: 1rem;">
                <button class="btn btn-primary" type="submit">Guardar alterações</button>
                <button type="button" class="btn btn-secondary" id="staffPromoCancelEdit">Cancelar</button>
            </div>
        </form>
        <form action="${pageContext.request.contextPath}/staff-promotions" method="post" style="margin-top: 0.75rem;" onsubmit="return confirm('Eliminar esta promoção?');">
            <input type="hidden" name="action" value="delete-promotion">
            <input type="hidden" name="idPromocao" value="<%= selPromo.getIdPromocao() %>">
            <button class="btn btn-secondary" type="submit" style="border-color: #b42318; color: #b42318;">Eliminar</button>
        </form>
    </div>
</div>
<% } %>

</div>

<script>
(function() {
  var root = document.getElementById('staffPromoRoot');
  if (!root) return;
  var base = root.getAttribute('data-promo-base') || '';
  var backdrop = document.getElementById('staffPromoBackdrop');
  var drawerCreate = document.getElementById('staffPromoDrawerCreate');
  var drawerEdit = document.getElementById('staffPromoDrawerEdit');
  var btnNovo = document.getElementById('staffPromoBtnNovo');
  var btnCloseC = document.getElementById('staffPromoCloseCreate');
  var btnCancelC = document.getElementById('staffPromoCancelCreate');
  var btnCloseE = document.getElementById('staffPromoCloseEdit');
  var btnCancelE = document.getElementById('staffPromoCancelEdit');
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
  } else if (drawerEdit && params.get('selectedPromocao')) {
    openEdit();
  }
  document.addEventListener('keydown', function(ev) {
    if (ev.key === 'Escape') {
      if (drawerCreate && drawerCreate.classList.contains('is-open')) closeCreate();
      else if (drawerEdit && drawerEdit.classList.contains('is-open')) closeEditNav();
    }
  });
  function fmtEuro(v) {
    return new Intl.NumberFormat('pt-PT', { style: 'currency', currency: 'EUR' }).format(v);
  }
  function syncPromoPreview(prefix) {
    var sel = document.getElementById('promoPac' + prefix);
    var preview = document.getElementById('promoPreview' + prefix);
    if (!sel || !preview) return;
    var opt = sel.options[sel.selectedIndex];
    if (!opt || !opt.value) {
      preview.hidden = true;
      return;
    }
    preview.hidden = false;
    var nome = opt.getAttribute('data-nome') || '';
    var dest = opt.getAttribute('data-destino') || '';
    var preco = parseFloat(opt.getAttribute('data-preco') || '0');
    document.getElementById('promoPreviewNome' + prefix).textContent = nome;
    document.getElementById('promoPreviewDest' + prefix).textContent = dest;
    document.getElementById('promoPreviewPreco' + prefix).textContent = fmtEuro(preco);
    var descInput = document.getElementById('promoDesc' + prefix);
    var pct = descInput ? parseFloat(descInput.value || '0') : 0;
    var finalP = preco * (1 - Math.min(90, Math.max(0, pct)) / 100);
    document.getElementById('promoPreviewFinal' + prefix).textContent =
      'Preço promocional (' + pct + '%): ' + fmtEuro(finalP);
    if (prefix === 'C') {
      var titulo = document.getElementById('promoTituloC');
      var destino = document.getElementById('promoDestC');
      if (titulo && !titulo.dataset.touched) titulo.value = nome ? 'Promoção — ' + nome : '';
      if (destino && !destino.dataset.touched) destino.value = dest;
    }
  }
  document.getElementById('promoPacC')?.addEventListener('change', function() { syncPromoPreview('C'); });
  document.getElementById('promoDescC')?.addEventListener('input', function() { syncPromoPreview('C'); });
  document.getElementById('promoTituloC')?.addEventListener('input', function() { this.dataset.touched = '1'; });
  document.getElementById('promoDestC')?.addEventListener('input', function() { this.dataset.touched = '1'; });
})();
</script>
