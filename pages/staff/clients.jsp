<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="flow staff-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Clientes" />
        <jsp:param name="heading" value="Gestão de clientes" />
        <jsp:param name="description" value="Consulta rapidamente clientes registados, estados de acompanhamento e ações disponíveis." />
    </jsp:include>

    <div class="staff-dashboard-grid">
        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Ativo</span>
                        <h2 style="font-size: 1.2rem;">Ana Silva</h2>
                    </div>
                    <span class="card__tag">CLI-101</span>
                </div>

                <p class="text-muted"><strong>Email:</strong> ana.silva@email.com</p>
                <p class="text-muted"><strong>Telefone:</strong> 912345678</p>
                <p class="text-muted"><strong>Última reserva:</strong> Maldivas Premium</p>
                <p class="text-muted"><strong>Estado:</strong> Cliente com reservas ativas</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-clients">Ver ficha</a>
                </div>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Recente</span>
                        <h2 style="font-size: 1.2rem;">João Costa</h2>
                    </div>
                    <span class="card__tag">CLI-102</span>
                </div>

                <p class="text-muted"><strong>Email:</strong> joao.costa@email.com</p>
                <p class="text-muted"><strong>Telefone:</strong> 934567890</p>
                <p class="text-muted"><strong>Última reserva:</strong> Roma Essencial</p>
                <p class="text-muted"><strong>Estado:</strong> Acompanhamento em curso</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-clients">Ver ficha</a>
                </div>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">VIP</span>
                        <h2 style="font-size: 1.2rem;">Marta Pereira</h2>
                    </div>
                    <span class="card__tag">CLI-103</span>
                </div>

                <p class="text-muted"><strong>Email:</strong> marta.pereira@email.com</p>
                <p class="text-muted"><strong>Telefone:</strong> 965432187</p>
                <p class="text-muted"><strong>Última reserva:</strong> Paris City Lights</p>
                <p class="text-muted"><strong>Estado:</strong> Cliente frequente</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-clients">Ver ficha</a>
                </div>
            </div>
        </div>
    </div>

    <%-- Duarte: esta página deverá mais tarde receber a lista real de clientes, histórico, estados e ações do staff. --%>
    <%-- Duarte: os botões de ficha estão temporariamente a redirecionar para a própria página apenas para demonstração frontend. Quando o backend estiver ligado, cada cliente deverá abrir a ficha real correspondente. --%>
</div>