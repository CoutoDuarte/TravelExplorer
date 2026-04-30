<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="flow staff-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Promoções" />
        <jsp:param name="heading" value="Gestão de promoções" />
        <jsp:param name="description" value="Consulta rapidamente campanhas ativas, promoções em preparação e ações comerciais disponíveis." />
    </jsp:include>

    <div class="staff-dashboard-grid">
        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Ativa</span>
                        <h2 style="font-size: 1.2rem;">Verão Tropical</h2>
                    </div>
                    <span class="card__tag">PROMO-201</span>
                </div>

                <p class="text-muted"><strong>Período:</strong> 01 Jul 2026 - 31 Ago 2026</p>
                <p class="text-muted"><strong>Destino:</strong> Maldivas e Bali</p>
                <p class="text-muted"><strong>Condição:</strong> Desconto até 15%</p>
                <p class="text-muted"><strong>Estado:</strong> Campanha publicada</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-promotions">Ver promoção</a>
                </div>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Planeada</span>
                        <h2 style="font-size: 1.2rem;">Escapadinhas Europeias</h2>
                    </div>
                    <span class="card__tag">PROMO-202</span>
                </div>

                <p class="text-muted"><strong>Período:</strong> 10 Set 2026 - 10 Out 2026</p>
                <p class="text-muted"><strong>Destino:</strong> Roma, Paris, Santorini</p>
                <p class="text-muted"><strong>Condição:</strong> Oferta de upgrade selecionado</p>
                <p class="text-muted"><strong>Estado:</strong> Em preparação</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-promotions">Ver promoção</a>
                </div>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                    <div class="flow" style="gap: 0.45rem;">
                        <span class="section-title__eyebrow">Concluída</span>
                        <h2 style="font-size: 1.2rem;">Primavera Cultural</h2>
                    </div>
                    <span class="card__tag">PROMO-203</span>
                </div>

                <p class="text-muted"><strong>Período:</strong> 15 Mar 2026 - 30 Abr 2026</p>
                <p class="text-muted"><strong>Destino:</strong> Paris e Roma</p>
                <p class="text-muted"><strong>Condição:</strong> Pack cultural promocional</p>
                <p class="text-muted"><strong>Estado:</strong> Campanha encerrada</p>

                <div class="actions-row">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-promotions">Ver promoção</a>
                </div>
            </div>
        </div>
    </div>

    
    
</div>