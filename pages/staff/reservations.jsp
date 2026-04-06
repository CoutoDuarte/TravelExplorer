<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="flow staff-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Reservas" />
        <jsp:param name="heading" value="Gestão de reservas" />
        <jsp:param name="description" value="Acompanha rapidamente as reservas em curso e consulta os respetivos estados." />
    </jsp:include>

    <div class="staff-dashboard-grid">
        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Confirmada</span>
                        <h2 style="font-size: 1.2rem;">Maldivas Premium</h2>
                    </div>
                    <span class="card__tag">RES-1001</span>
                </div>

                <p class="text-muted"><strong>Cliente:</strong> Ana Silva</p>
                <p class="text-muted"><strong>Datas:</strong> 12 Ago 2026 - 19 Ago 2026</p>
                <p class="text-muted"><strong>Viajantes:</strong> 2 viajantes</p>
                <p class="text-muted"><strong>Estado:</strong> Reserva confirmada</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-reservations">Ver detalhes</a>
                </div>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Em preparação</span>
                        <h2 style="font-size: 1.2rem;">Roma Essencial</h2>
                    </div>
                    <span class="card__tag">RES-1002</span>
                </div>

                <p class="text-muted"><strong>Cliente:</strong> João Costa</p>
                <p class="text-muted"><strong>Datas:</strong> 03 Set 2026 - 07 Set 2026</p>
                <p class="text-muted"><strong>Viajantes:</strong> 1 viajante</p>
                <p class="text-muted"><strong>Estado:</strong> A aguardar confirmação final</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-reservations">Ver detalhes</a>
                </div>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Concluída</span>
                        <h2 style="font-size: 1.2rem;">Paris City Lights</h2>
                    </div>
                    <span class="card__tag">RES-1003</span>
                </div>

                <p class="text-muted"><strong>Cliente:</strong> Marta Pereira</p>
                <p class="text-muted"><strong>Datas:</strong> 22 Jul 2026 - 26 Jul 2026</p>
                <p class="text-muted"><strong>Viajantes:</strong> 2 viajantes</p>
                <p class="text-muted"><strong>Estado:</strong> Viagem concluída</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-reservations">Ver detalhes</a>
                </div>
            </div>
        </div>
    </div>

    <%-- Duarte: esta página deverá mais tarde receber a lista real de reservas, estados, clientes e ações operacionais do staff. --%>
    <%-- Duarte: os botões de detalhe estão temporariamente a redirecionar para a própria página apenas para demonstração frontend. Quando o backend estiver ligado, cada reserva deverá abrir o detalhe real correspondente. --%>
</div>