<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="flow staff-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Comunicação" />
        <jsp:param name="heading" value="Gestão de comunicação" />
        <jsp:param name="description" value="Consulta campanhas, comunicações preparadas e ações de contacto previstas para clientes." />
    </jsp:include>

    <div class="staff-dashboard-grid">
        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Enviado</span>
                        <h2 style="font-size: 1.2rem;">Campanha Verão Tropical</h2>
                    </div>
                    <span class="card__tag">COM-301</span>
                </div>

                <p class="text-muted"><strong>Canal:</strong> Email</p>
                <p class="text-muted"><strong>Segmento:</strong> Clientes com interesse em praia</p>
                <p class="text-muted"><strong>Data:</strong> 02 Jul 2026</p>
                <p class="text-muted"><strong>Estado:</strong> Comunicação enviada</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-communication">Ver campanha</a>
                </div>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Planeada</span>
                        <h2 style="font-size: 1.2rem;">Newsletter Escapadinhas</h2>
                    </div>
                    <span class="card__tag">COM-302</span>
                </div>

                <p class="text-muted"><strong>Canal:</strong> Email</p>
                <p class="text-muted"><strong>Segmento:</strong> Clientes urbanos</p>
                <p class="text-muted"><strong>Data:</strong> 15 Set 2026</p>
                <p class="text-muted"><strong>Estado:</strong> Aguardar validação</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-communication">Ver campanha</a>
                </div>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Rascunho</span>
                        <h2 style="font-size: 1.2rem;">Clientes VIP Outono</h2>
                    </div>
                    <span class="card__tag">COM-303</span>
                </div>

                <p class="text-muted"><strong>Canal:</strong> Email e contacto direto</p>
                <p class="text-muted"><strong>Segmento:</strong> Clientes frequentes</p>
                <p class="text-muted"><strong>Data:</strong> Em definição</p>
                <p class="text-muted"><strong>Estado:</strong> Em preparação</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-communication">Ver campanha</a>
                </div>
            </div>
        </div>
    </div>

    
    
</div>