<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,java.util.HashSet,java.util.Set,Connection.Classes.Pacote,Connection.Classes.Viagens,Connection.Classes.Alojamento,Connection.Classes.Transporte,Connection.CRUD.PacoteCRUD,Connection.CRUD.ViagemCRUD,Connection.CRUD.AlojamentoCRUD,Connection.CRUD.TransporteCRUD" %>
<%
PacoteCRUD pacoteCRUD = new PacoteCRUD();
ViagemCRUD viagemCRUD = new ViagemCRUD();
AlojamentoCRUD alojamentoCRUD = new AlojamentoCRUD();
TransporteCRUD transporteCRUD = new TransporteCRUD();
List<Pacote> pacotes = pacoteCRUD.findAll();
List<Viagens> todasViagens = viagemCRUD.findAll();
List<Alojamento> todosAlojamentos = alojamentoCRUD.findAll();
List<Transporte> todosTransportes = transporteCRUD.findAll();
String selectedParam = request.getParameter("selectedPacote");
Pacote selecionado = null;
if (selectedParam != null && !selectedParam.trim().isEmpty()) {
    try {
        int sid = Integer.parseInt(selectedParam.trim());
        selecionado = pacoteCRUD.findById(sid);
    } catch (NumberFormatException ignored) {
    }
}
String success = request.getParameter("success");
String error = request.getParameter("error");
List<Viagens> viagensPacote = selecionado != null ? viagemCRUD.findByPacote(selecionado.getIdPacote()) : java.util.Collections.emptyList();
List<Alojamento> alojPacote = selecionado != null ? alojamentoCRUD.findByPacote(selecionado.getIdPacote()) : java.util.Collections.emptyList();
List<Transporte> transPacote = selecionado != null ? transporteCRUD.findByPacote(selecionado.getIdPacote()) : java.util.Collections.emptyList();
Set<Integer> idsV = new HashSet<>();
for (Viagens v : viagensPacote) {
    idsV.add(v.getIdViagem());
}
Set<Integer> idsA = new HashSet<>();
for (Alojamento a : alojPacote) {
    idsA.add(a.getIdAlojamento());
}
Set<Integer> idsT = new HashSet<>();
for (Transporte t : transPacote) {
    idsT.add(t.getIdTransporte());
}
java.text.DecimalFormatSymbols sym = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
sym.setDecimalSeparator(',');
sym.setGroupingSeparator(' ');
java.text.DecimalFormat dfPreco = new java.text.DecimalFormat("#,##0.00", sym);
String offersBase = request.getContextPath() + "/index.jsp?page=staff-offers";
boolean selectedInvalid = selectedParam != null && !selectedParam.trim().isEmpty() && selecionado == null;
%>

<div id="staffOffersRoot" class="staff-shell staff-offers-page" data-offers-base="<%= offersBase %>">

<div class="flow">

    <% if ("package-created".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Pacote criado com sucesso.</div></div>
    <% } %>
    <% if ("package-updated".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Pacote atualizado com sucesso.</div></div>
    <% } %>
    <% if ("package-deleted".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Pacote eliminado com sucesso.</div></div>
    <% } %>
    <% if ("relation-updated".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Associações atualizadas.</div></div>
    <% } %>
    <% if ("invalid-data".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Dados inválidos. Verifica os campos obrigatórios e os valores numéricos.</div></div>
    <% } %>
    <% if (selectedInvalid) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Pacote não encontrado.</div></div>
    <% } %>

    <div class="staff-offers-page-header">
        <div class="section-title">
            <span class="section-title__eyebrow">Ofertas</span>
            <h1 class="section-title__heading">Gestão de ofertas e pacotes</h1>
            <p class="section-title__description">Lista e gere pacotes comerciais (PACOTE), associa viagens, alojamentos e transportes. As alterações refletem-se na área pública de ofertas.</p>
        </div>
        <div class="actions-row" style="flex-shrink: 0;">
            <button type="button" class="btn btn-primary" id="staffOffersBtnNovo">+ Novo pacote</button>
        </div>
    </div>

    <div class="surface-block surface-block-lg staff-action-panel">
        <% if (pacotes == null || pacotes.isEmpty()) { %>
        <div class="staff-offers-empty">
            <p class="text-muted" style="margin-bottom: 1rem;">Ainda não existem pacotes registados.</p>
            <button type="button" class="btn btn-primary" id="staffOffersBtnNovoEmpty">+ Novo pacote</button>
        </div>
        <% } else { %>
        <div class="staff-offers-table-wrap">
            <table class="staff-offers-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nome</th>
                        <th>Preço base</th>
                        <th>Adultos</th>
                        <th>Crianças</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Pacote p : pacotes) { %>
                    <tr>
                        <td><%= p.getIdPacote() %></td>
                        <td><strong><%= p.getNome() != null ? p.getNome() : "" %></strong></td>
                        <td><%= dfPreco.format(p.getPrecoBase()) %> €</td>
                        <td><%= p.getNumAdultos() %></td>
                        <td><%= p.getNumCriancas() %></td>
                        <td><a class="btn btn-secondary" style="padding: 0.35rem 0.65rem; font-size: 0.85rem;" href="<%= offersBase %>&amp;selectedPacote=<%= p.getIdPacote() %>">Gerir</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
    </div>

    <div id="staffOffersBackdrop" class="staff-drawer-backdrop" aria-hidden="true"></div>

    <div id="staffOffersDrawerCreate" class="staff-drawer" aria-hidden="true">
        <div class="staff-drawer__header">
            <h2 class="staff-drawer__title">Novo pacote</h2>
            <button type="button" class="staff-drawer__close" id="staffOffersCloseCreate" aria-label="Fechar">&times;</button>
        </div>
        <div class="staff-drawer__body flow">
            <form class="flow" action="${pageContext.request.contextPath}/staff-offers" method="post">
                <input type="hidden" name="action" value="create-package">
                <div>
                    <label for="createNome">Nome</label>
                    <input type="text" id="createNome" name="nome" required>
                </div>
                <div>
                    <label for="createDesc">Descrição</label>
                    <textarea id="createDesc" name="descricao" rows="4" required></textarea>
                </div>
                <div>
                    <label for="createPreco">Preço base (€)</label>
                    <input type="number" id="createPreco" name="preco_base" step="0.01" min="0" required>
                </div>
                <div>
                    <label for="createAdultos">Número de adultos</label>
                    <input type="number" id="createAdultos" name="numero_pessoas_adultas" min="0" required>
                </div>
                <div>
                    <label for="createCriancas">Número de crianças</label>
                    <input type="number" id="createCriancas" name="numero_criancas" min="0" required>
                </div>
                <div class="actions-row" style="margin-top: 1rem;">
                    <button class="btn btn-primary" type="submit">Criar pacote</button>
                    <button type="button" class="btn btn-secondary" id="staffOffersCancelCreate">Cancelar</button>
                </div>
            </form>
        </div>
    </div>

    <% if (selecionado != null) { %>
    <div id="staffOffersDrawerEdit" class="staff-drawer" aria-hidden="true">
        <div class="staff-drawer__header">
            <h2 class="staff-drawer__title">Pacote #<%= selecionado.getIdPacote() %></h2>
            <button type="button" class="staff-drawer__close" id="staffOffersCloseEdit" aria-label="Fechar">&times;</button>
        </div>
        <div class="staff-drawer__body flow">
            <p class="text-muted" style="font-size: 0.9rem;"><%= selecionado.getNome() != null ? selecionado.getNome() : "" %></p>

            <form class="flow" action="${pageContext.request.contextPath}/staff-offers" method="post">
                <input type="hidden" name="action" value="update-package">
                <input type="hidden" name="idPacote" value="<%= selecionado.getIdPacote() %>">
                <div>
                    <label for="editNome">Nome</label>
                    <% String editNomeEsc = selecionado.getNome() != null
                        ? selecionado.getNome().replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;")
                        : ""; %>
                    <input type="text" id="editNome" name="nome" value="<%= editNomeEsc %>" required>
                </div>
                <div>
                    <label for="editDesc">Descrição</label>
                    <textarea id="editDesc" name="descricao" rows="4" required><%= selecionado.getDescricao() != null ? selecionado.getDescricao() : "" %></textarea>
                </div>
                <div>
                    <label for="editPreco">Preço base (€)</label>
                    <input type="number" id="editPreco" name="preco_base" step="0.01" min="0" value="<%= selecionado.getPrecoBase() %>" required>
                </div>
                <div>
                    <label for="editAdultos">Número de adultos</label>
                    <input type="number" id="editAdultos" name="numero_pessoas_adultas" min="0" value="<%= selecionado.getNumAdultos() %>" required>
                </div>
                <div>
                    <label for="editCriancas">Número de crianças</label>
                    <input type="number" id="editCriancas" name="numero_criancas" min="0" value="<%= selecionado.getNumCriancas() %>" required>
                </div>
                <div class="actions-row" style="margin-top: 1rem;">
                    <button class="btn btn-primary" type="submit">Guardar alterações</button>
                </div>
            </form>
            <form action="${pageContext.request.contextPath}/staff-offers" method="post" style="margin-top: 0.75rem;" onsubmit="return confirm('Tens a certeza de que queres eliminar este pacote?');">
                <input type="hidden" name="action" value="delete-package">
                <input type="hidden" name="idPacote" value="<%= selecionado.getIdPacote() %>">
                <button class="btn btn-secondary" type="submit" style="border-color: #b42318; color: #b42318;">Eliminar</button>
            </form>

            <hr style="border: none; border-top: 1px solid rgba(15, 23, 42, 0.1); margin: 1.25rem 0;">

            <div class="staff-dashboard-grid">
                <div class="surface-block staff-summary-card">
                    <div class="flow">
                        <span class="section-title__eyebrow">Viagens</span>
                        <h3 style="font-size: 1rem; margin: 0;">Associadas</h3>
                        <% if (viagensPacote.isEmpty()) { %>
                        <p class="text-muted" style="font-size: 0.88rem;">Sem viagens associadas.</p>
                        <% } else { %>
                        <ul class="text-muted" style="list-style: disc; padding-left: 1.1rem; font-size: 0.88rem;">
                            <% for (Viagens v : viagensPacote) { %>
                            <li>
                                <%= v.getOrigem() %> → <%= v.getDestino() %>
                                <form action="${pageContext.request.contextPath}/staff-offers" method="post" style="display: inline; margin-left: 0.35rem;">
                                    <input type="hidden" name="action" value="detach-viagem">
                                    <input type="hidden" name="idPacote" value="<%= selecionado.getIdPacote() %>">
                                    <input type="hidden" name="idViagem" value="<%= v.getIdViagem() %>">
                                    <button class="btn btn-ghost" type="submit" style="padding: 0.1rem 0.45rem; font-size: 0.8rem;">Remover</button>
                                </form>
                            </li>
                            <% } %>
                        </ul>
                        <% } %>
                        <% if (todasViagens == null || todasViagens.isEmpty()) { %>
                        <p class="text-muted" style="font-size: 0.85rem;">Ainda não existem viagens registadas na base de dados.</p>
                        <% } else {
                            boolean anyV = false;
                            for (Viagens v : todasViagens) {
                                if (!idsV.contains(v.getIdViagem())) { anyV = true; break; }
                            }
                            if (!anyV) { %>
                        <p class="text-muted" style="font-size: 0.85rem;">Não há mais viagens para associar.</p>
                        <% } else { %>
                        <form class="flow" action="${pageContext.request.contextPath}/staff-offers" method="post" style="margin-top: 0.5rem;">
                            <input type="hidden" name="action" value="attach-viagem">
                            <input type="hidden" name="idPacote" value="<%= selecionado.getIdPacote() %>">
                            <label for="selViagem">Associar viagem</label>
                            <select id="selViagem" name="idViagem" required>
                                <% for (Viagens v : todasViagens) {
                                    if (idsV.contains(v.getIdViagem())) continue; %>
                                <option value="<%= v.getIdViagem() %>"><%= v.getOrigem() %> → <%= v.getDestino() %> (#<%= v.getIdViagem() %>)</option>
                                <% } %>
                            </select>
                            <button class="btn btn-secondary" type="submit" style="margin-top: 0.45rem;">Associar viagem</button>
                        </form>
                        <% } } %>
                    </div>
                </div>
                <div class="surface-block staff-summary-card">
                    <div class="flow">
                        <span class="section-title__eyebrow">Alojamentos</span>
                        <h3 style="font-size: 1rem; margin: 0;">Associados</h3>
                        <% if (alojPacote.isEmpty()) { %>
                        <p class="text-muted" style="font-size: 0.88rem;">Sem alojamentos associados.</p>
                        <% } else { %>
                        <ul class="text-muted" style="list-style: disc; padding-left: 1.1rem; font-size: 0.88rem;">
                            <% for (Alojamento a : alojPacote) { %>
                            <li>
                                <%= a.getNome() %>
                                <form action="${pageContext.request.contextPath}/staff-offers" method="post" style="display: inline; margin-left: 0.35rem;">
                                    <input type="hidden" name="action" value="detach-alojamento">
                                    <input type="hidden" name="idPacote" value="<%= selecionado.getIdPacote() %>">
                                    <input type="hidden" name="idAlojamento" value="<%= a.getIdAlojamento() %>">
                                    <button class="btn btn-ghost" type="submit" style="padding: 0.1rem 0.45rem; font-size: 0.8rem;">Remover</button>
                                </form>
                            </li>
                            <% } %>
                        </ul>
                        <% } %>
                        <% if (todosAlojamentos == null || todosAlojamentos.isEmpty()) { %>
                        <p class="text-muted" style="font-size: 0.85rem;">Ainda não existem alojamentos registados na base de dados.</p>
                        <% } else {
                            boolean anyA = false;
                            for (Alojamento a : todosAlojamentos) {
                                if (!idsA.contains(a.getIdAlojamento())) { anyA = true; break; }
                            }
                            if (!anyA) { %>
                        <p class="text-muted" style="font-size: 0.85rem;">Não há mais alojamentos para associar.</p>
                        <% } else { %>
                        <form class="flow" action="${pageContext.request.contextPath}/staff-offers" method="post" style="margin-top: 0.5rem;">
                            <input type="hidden" name="action" value="attach-alojamento">
                            <input type="hidden" name="idPacote" value="<%= selecionado.getIdPacote() %>">
                            <label for="selAloj">Associar alojamento</label>
                            <select id="selAloj" name="idAlojamento" required>
                                <% for (Alojamento a : todosAlojamentos) {
                                    if (idsA.contains(a.getIdAlojamento())) continue; %>
                                <option value="<%= a.getIdAlojamento() %>"><%= a.getNome() %> (#<%= a.getIdAlojamento() %>)</option>
                                <% } %>
                            </select>
                            <button class="btn btn-secondary" type="submit" style="margin-top: 0.45rem;">Associar alojamento</button>
                        </form>
                        <% } } %>
                    </div>
                </div>
                <div class="surface-block staff-summary-card">
                    <div class="flow">
                        <span class="section-title__eyebrow">Transportes</span>
                        <h3 style="font-size: 1rem; margin: 0;">Associados</h3>
                        <% if (transPacote.isEmpty()) { %>
                        <p class="text-muted" style="font-size: 0.88rem;">Sem transportes associados.</p>
                        <% } else { %>
                        <ul class="text-muted" style="list-style: disc; padding-left: 1.1rem; font-size: 0.88rem;">
                            <% for (Transporte t : transPacote) { %>
                            <li>
                                <%= t.getTipo() %> — <%= t.getOrigem() %> → <%= t.getDestino() %>
                                <form action="${pageContext.request.contextPath}/staff-offers" method="post" style="display: inline; margin-left: 0.35rem;">
                                    <input type="hidden" name="action" value="detach-transporte">
                                    <input type="hidden" name="idPacote" value="<%= selecionado.getIdPacote() %>">
                                    <input type="hidden" name="idTransporte" value="<%= t.getIdTransporte() %>">
                                    <button class="btn btn-ghost" type="submit" style="padding: 0.1rem 0.45rem; font-size: 0.8rem;">Remover</button>
                                </form>
                            </li>
                            <% } %>
                        </ul>
                        <% } %>
                        <% if (todosTransportes == null || todosTransportes.isEmpty()) { %>
                        <p class="text-muted" style="font-size: 0.85rem;">Ainda não existem transportes registados na base de dados.</p>
                        <% } else {
                            boolean anyTr = false;
                            for (Transporte tx : todosTransportes) {
                                if (!idsT.contains(tx.getIdTransporte())) { anyTr = true; break; }
                            }
                            if (!anyTr) { %>
                        <p class="text-muted" style="font-size: 0.85rem;">Não há mais transportes para associar.</p>
                        <% } else { %>
                        <form class="flow" action="${pageContext.request.contextPath}/staff-offers" method="post" style="margin-top: 0.5rem;">
                            <input type="hidden" name="action" value="attach-transporte">
                            <input type="hidden" name="idPacote" value="<%= selecionado.getIdPacote() %>">
                            <label for="selTrans">Associar transporte</label>
                            <select id="selTrans" name="idTransporte" required>
                                <% for (Transporte tx : todosTransportes) {
                                    if (idsT.contains(tx.getIdTransporte())) continue; %>
                                <option value="<%= tx.getIdTransporte() %>"><%= tx.getTipo() %> (#<%= tx.getIdTransporte() %>)</option>
                                <% } %>
                            </select>
                            <button class="btn btn-secondary" type="submit" style="margin-top: 0.45rem;">Associar transporte</button>
                        </form>
                        <% } } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <% } %>
</div>

<script>
(function() {
  var root = document.getElementById('staffOffersRoot');
  if (!root) return;
  var base = root.getAttribute('data-offers-base') || '';
  var backdrop = document.getElementById('staffOffersBackdrop');
  var drawerCreate = document.getElementById('staffOffersDrawerCreate');
  var drawerEdit = document.getElementById('staffOffersDrawerEdit');
  var btnNovo = document.getElementById('staffOffersBtnNovo');
  var btnNovoEmpty = document.getElementById('staffOffersBtnNovoEmpty');
  var btnCloseCreate = document.getElementById('staffOffersCloseCreate');
  var btnCancelCreate = document.getElementById('staffOffersCancelCreate');
  var btnCloseEdit = document.getElementById('staffOffersCloseEdit');
  function lockScroll(on) {
    document.body.style.overflow = on ? 'hidden' : '';
  }
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
  function closeEditNav() {
    window.location.href = base;
  }
  if (btnNovo) btnNovo.addEventListener('click', openCreate);
  if (btnNovoEmpty) btnNovoEmpty.addEventListener('click', openCreate);
  if (btnCloseCreate) {
    btnCloseCreate.addEventListener('click', function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      closeCreate();
    });
  }
  if (btnCancelCreate) {
    btnCancelCreate.addEventListener('click', function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      closeCreate();
    });
  }
  if (backdrop) {
    backdrop.addEventListener('click', function(ev) {
      if (ev.target !== backdrop) {
        return;
      }
      if (drawerCreate && drawerCreate.classList.contains('is-open')) {
        closeCreate();
        return;
      }
      if (drawerEdit && drawerEdit.classList.contains('is-open')) {
        closeEditNav();
      }
    });
  }
  if (btnCloseEdit) btnCloseEdit.addEventListener('click', closeEditNav);
  var params = new URLSearchParams(window.location.search);
  if (params.get('openCreate') === '1') {
    if (window.history && window.history.replaceState) {
      window.history.replaceState({}, '', base);
    }
    openCreate();
  } else if (drawerEdit && params.get('selectedPacote')) {
    openEdit();
  }
  document.addEventListener('keydown', function(ev) {
    if (ev.key === 'Escape') {
      if (drawerCreate && drawerCreate.classList.contains('is-open')) {
        closeCreate();
      } else if (drawerEdit && drawerEdit.classList.contains('is-open')) {
        closeEditNav();
      }
    }
  });
})();
</script>
