<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Dashboard" />
        <jsp:param name="heading" value="Bem-vindo à tua área de cliente" />
        <jsp:param name="description" value="Consulta rapidamente o estado das tuas reservas, ofertas guardadas e próximos passos." />
    </jsp:include>

    <div class="customer-dashboard-grid">
        <div class="surface-block customer-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Reservas</span>
                <h2 style="font-size: 1.25rem;">2 reservas ativas</h2>
                <p class="text-muted">Acompanha viagens em preparação e consulta os detalhes mais recentes.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=my-reservations">Ver reservas</a>
            </div>
        </div>

        <div class="surface-block customer-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Guardados</span>
                <h2 style="font-size: 1.25rem;">4 ofertas favoritas</h2>
                <p class="text-muted">Revê rapidamente as ofertas que guardaste para comparar mais tarde.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=saved-offers">Ver ofertas guardadas</a>
            </div>
        </div>

        <div class="surface-block customer-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Perfil</span>
                <h2 style="font-size: 1.25rem;">Dados da conta</h2>
                <p class="text-muted">Atualiza os teus dados pessoais e prepara a tua experiência futura na plataforma.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=profile">Ver perfil</a>
            </div>
        </div>
    </div>

    <div class="surface-block surface-block-lg customer-action-panel">
        <div class="flow">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Próximos passos" />
                <jsp:param name="heading" value="Continua a explorar o TravelExplorer" />
                <jsp:param name="description" value="Esta área servirá mais tarde para mostrar ações rápidas e informação personalizada do cliente." />
            </jsp:include>

            <div class="actions-row">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/index.jsp?page=offers">Explorar ofertas</a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=profile">Gerir conta</a>
            </div>
        </div>
    </div>
</div>