<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,Connection.Classes.Funcionario,Connection.Classes.Funcao,Connection.CRUD.FuncionarioCRUD,Connection.CRUD.FuncaoCRUD,Connection.Security.StaffAuth" %>
<%
FuncionarioCRUD funcionarioCRUD = new FuncionarioCRUD();
FuncaoCRUD funcaoCRUD = new FuncaoCRUD();
List<Funcionario> funcionarios = funcionarioCRUD.findAll();
List<Funcao> funcoes = funcaoCRUD.findAll();
boolean podeCriarContas = StaffAuth.hasPermission(request, "STAFF_CREATE_USERS");
String success = request.getParameter("success");
String error = request.getParameter("error");
String adminBase = request.getContextPath() + "/index.jsp?page=staff-admin";
%>

<div id="staffAdminRoot" class="staff-shell staff-offers-page" data-admin-base="<%= adminBase %>">

<div class="flow">
    <% if ("staff-created".equals(success)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--success">Conta interna criada com sucesso.</div></div>
    <% } %>
    <% if ("email-exists".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Já existe um colaborador com este email.</div></div>
    <% } %>
    <% if ("invalid-data".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Dados inválidos. Verifica os campos obrigatórios.</div></div>
    <% } %>
    <% if ("no-permission".equals(error)) { %>
    <div class="staff-offers-alert-wrap"><div class="staff-offers-alert staff-offers-alert--error">Não tens permissão para realizar esta operação.</div></div>
    <% } %>

    <div class="staff-offers-page-header">
        <div class="section-title">
            <span class="section-title__eyebrow">Administração</span>
            <h1 class="section-title__heading">Administração</h1>
            <p class="section-title__description">Consulta a equipa interna, funções atribuídas e cria novas contas de colaboradores quando tiveres permissão.</p>
        </div>
        <% if (podeCriarContas) { %>
        <div class="actions-row" style="flex-shrink: 0;">
            <button type="button" class="btn btn-primary" id="staffAdminBtnNovo">+ Novo colaborador</button>
        </div>
        <% } %>
    </div>

    <div class="surface-block surface-block-lg staff-action-panel">
        <jsp:include page="/components/shared/section_title.jsp">
            <jsp:param name="eyebrow" value="Equipa" />
            <jsp:param name="heading" value="Colaboradores internos" />
            <jsp:param name="description" value="Lista de funcionários com contactos, remuneração base e funções associadas." />
        </jsp:include>
        <% if (funcionarios == null || funcionarios.isEmpty()) { %>
        <p class="text-muted" style="margin-top: 1rem;">Sem colaboradores registados.</p>
        <% } else { %>
        <div class="staff-offers-table-wrap" style="margin-top: 1rem;">
            <table class="staff-offers-table">
                <thead>
                    <tr>
                        <th>Nome</th>
                        <th>Email</th>
                        <th>Telemóvel</th>
                        <th>Salário</th>
                        <th>Funções</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Funcionario fu : funcionarios) {
                        List<Funcao> funcoesColaborador = funcaoCRUD.findByFuncionarioId(fu.getIdFuncionario());
                        StringBuilder nomesFuncoes = new StringBuilder();
                        for (int i = 0; i < funcoesColaborador.size(); i++) {
                            if (i > 0) nomesFuncoes.append(", ");
                            nomesFuncoes.append(funcoesColaborador.get(i).getNome());
                        }
                    %>
                    <tr>
                        <td><%= fu.getNome() %></td>
                        <td><%= fu.getEmail() %></td>
                        <td><%= fu.getTelemovel() %></td>
                        <td><%= fu.getSalario() %></td>
                        <td><%= nomesFuncoes.length() == 0 ? "—" : nomesFuncoes.toString() %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>

    <% if (!podeCriarContas) { %>
    <div class="surface-block surface-block-lg staff-action-panel" style="margin-top: 1rem;">
        <p class="text-muted">Não tem permissão para criar contas internas.</p>
    </div>
    <% } %>
</div>

<% if (podeCriarContas) { %>
<div id="staffAdminBackdrop" class="staff-drawer-backdrop" aria-hidden="true"></div>
<div id="staffAdminDrawerCreate" class="staff-drawer" aria-hidden="true">
    <div class="staff-drawer__header">
        <h2 class="staff-drawer__title">Novo colaborador</h2>
        <button type="button" class="staff-drawer__close" id="staffAdminCloseCreate" aria-label="Fechar">&times;</button>
    </div>
    <div class="staff-drawer__body flow">
        <% if (funcoes == null || funcoes.isEmpty()) { %>
        <p class="text-muted">Não existem funções disponíveis para atribuir.</p>
        <% } else { %>
        <form class="flow" action="${pageContext.request.contextPath}/staff-admin" method="post">
            <div>
                <label for="staffNome">Nome</label>
                <input type="text" id="staffNome" name="nome" required>
            </div>
            <div>
                <label for="staffEmail">Email</label>
                <input type="email" id="staffEmail" name="email" required>
            </div>
            <div>
                <label for="staffTelefone">Telemóvel</label>
                <input type="number" id="staffTelefone" name="telefone" required>
            </div>
            <div>
                <label for="staffSalario">Salário</label>
                <input type="number" id="staffSalario" name="salario" step="0.01" min="0" required>
            </div>
            <div>
                <label for="staffPassword">Palavra-passe</label>
                <input type="password" id="staffPassword" name="password" required>
            </div>
            <div>
                <label for="staffIdFuncao">Função</label>
                <select id="staffIdFuncao" name="idFuncao" required>
                    <% for (Funcao fn : funcoes) { %>
                    <option value="<%= fn.getIdFuncao() %>"><%= fn.getNome() %></option>
                    <% } %>
                </select>
            </div>
            <div class="actions-row" style="margin-top: 1rem;">
                <button class="btn btn-primary" type="submit">Criar conta</button>
                <button type="button" class="btn btn-secondary" id="staffAdminCancelCreate">Cancelar</button>
            </div>
        </form>
        <% } %>
    </div>
</div>
<% } %>

</div>

<% if (podeCriarContas) { %>
<script>
(function() {
  var root = document.getElementById('staffAdminRoot');
  if (!root) return;
  var base = root.getAttribute('data-admin-base') || '';
  var backdrop = document.getElementById('staffAdminBackdrop');
  var drawer = document.getElementById('staffAdminDrawerCreate');
  var btnNovo = document.getElementById('staffAdminBtnNovo');
  var btnClose = document.getElementById('staffAdminCloseCreate');
  var btnCancel = document.getElementById('staffAdminCancelCreate');
  function lockScroll(on) { document.body.style.overflow = on ? 'hidden' : ''; }
  function openDr() {
    if (!backdrop || !drawer) return;
    backdrop.classList.add('is-open');
    drawer.classList.add('is-open');
    backdrop.setAttribute('aria-hidden', 'false');
    drawer.setAttribute('aria-hidden', 'false');
    lockScroll(true);
  }
  function closeDr() {
    if (!backdrop || !drawer) return;
    drawer.classList.remove('is-open');
    drawer.setAttribute('aria-hidden', 'true');
    backdrop.classList.remove('is-open');
    backdrop.setAttribute('aria-hidden', 'true');
    lockScroll(false);
  }
  if (btnNovo) btnNovo.addEventListener('click', openDr);
  if (btnClose) btnClose.addEventListener('click', function(ev) { ev.preventDefault(); ev.stopPropagation(); closeDr(); });
  if (btnCancel) btnCancel.addEventListener('click', function(ev) { ev.preventDefault(); ev.stopPropagation(); closeDr(); });
  if (backdrop) backdrop.addEventListener('click', function(ev) { if (ev.target === backdrop && drawer.classList.contains('is-open')) closeDr(); });
  document.addEventListener('keydown', function(ev) {
    if (ev.key === 'Escape' && drawer && drawer.classList.contains('is-open')) closeDr();
  });
  if (new URLSearchParams(window.location.search).get('openCreate') === '1') {
    if (window.history && window.history.replaceState) window.history.replaceState({}, '', base);
    openDr();
  }
})();
</script>
<% } %>
