<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="flow staff-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Administração" />
        <jsp:param name="heading" value="Painel de administração" />
        <jsp:param name="description" value="Consulta definições gerais, gestão interna e ações administrativas da plataforma." />
    </jsp:include>

    <div class="staff-dashboard-grid">
        <div class="surface-block staff-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Utilizadores</span>
                <h2 style="font-size: 1.2rem;">Gestão de contas internas</h2>
                <p class="text-muted">Acede futuramente à criação, edição e gestão de perfis da equipa.</p>
                <span class="btn btn-secondary" style="pointer-events: none; opacity: 0.78;">Gerir utilizadores</span>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Permissões</span>
                <h2 style="font-size: 1.2rem;">Controlo de acessos</h2>
                <p class="text-muted">Consulta e organiza permissões para diferentes perfis internos.</p>
                <span class="btn btn-secondary" style="pointer-events: none; opacity: 0.78;">Gerir permissões</span>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Configuração</span>
                <h2 style="font-size: 1.2rem;">Parâmetros gerais</h2>
                <p class="text-muted">Prepara a futura gestão de configurações centrais da plataforma.</p>
                <span class="btn btn-secondary" style="pointer-events: none; opacity: 0.78;">Ver definições</span>
            </div>
        </div>
    </div>

    <div class="surface-block surface-block-lg staff-action-panel">
        <div class="flow">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Operações" />
                <jsp:param name="heading" value="Ações administrativas principais" />
                <jsp:param name="description" value="Esta área poderá mais tarde concentrar ações críticas de gestão, supervisão e manutenção interna." />
            </jsp:include>

            <div class="actions-row">
                <span class="btn btn-primary" style="pointer-events: none; opacity: 0.88;">Criar utilizador</span>
                <span class="btn btn-secondary" style="pointer-events: none; opacity: 0.78;">Rever acessos</span>
                <span class="btn btn-secondary" style="pointer-events: none; opacity: 0.78;">Configurar sistema</span>
            </div>
        </div>
    </div>

    
    
</div>