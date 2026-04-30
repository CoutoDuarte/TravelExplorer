<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="flow staff-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Dashboard" />
        <jsp:param name="heading" value="Painel principal da área staff" />
        <jsp:param name="description" value="Acompanha rapidamente o estado geral da plataforma, reservas, clientes e ações prioritárias." />
    </jsp:include>

    <div class="staff-dashboard-grid">
        <div class="surface-block staff-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Reservas</span>
                <h2 style="font-size: 1.25rem;">18 reservas ativas</h2>
                <p class="text-muted">Consulta rapidamente o volume atual de reservas em processamento.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-reservations">Ver reservas</a>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Clientes</span>
                <h2 style="font-size: 1.25rem;">246 clientes registados</h2>
                <p class="text-muted">Acompanha o crescimento da base de clientes e os contactos principais.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-clients">Ver clientes</a>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Promoções</span>
                <h2 style="font-size: 1.25rem;">6 campanhas ativas</h2>
                <p class="text-muted">Revê rapidamente as promoções publicadas e ações comerciais em curso.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-promotions">Ver promoções</a>
            </div>
        </div>
    </div>

    <div class="surface-block surface-block-lg staff-action-panel">
        <div class="flow">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Ações rápidas" />
                <jsp:param name="heading" value="Atalhos para as tarefas mais importantes" />
                <jsp:param name="description" value="Esta área poderá mais tarde concentrar atalhos operacionais e alertas importantes para o staff." />
            </jsp:include>

            <div class="actions-row">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/index.jsp?page=staff-reservations">Nova reserva</a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-clients">Novo cliente</a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-promotions">Nova promoção</a>
                <a class="btn btn-ghost" href="${pageContext.request.contextPath}/index.jsp?page=offers">Ver área pública</a>
            </div>
        </div>
    </div>

    
    
</div>