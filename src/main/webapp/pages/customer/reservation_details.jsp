<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Reserva" />
        <jsp:param name="heading" value="Detalhes da reserva" />
        <jsp:param name="description" value="Consulta o estado da reserva, informação principal e próximos passos." />
    </jsp:include>

    <div class="surface-block surface-block-lg customer-action-panel">
        <div class="flow">
            <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
                <div class="flow" style="gap: 0.45rem;">
                    <span class="section-title__eyebrow">Confirmada</span>
                    <h2 style="font-size: 1.45rem;">Maldivas Premium</h2>
                </div>

                <span class="card__tag">RES-1001</span>
            </div>

            <div class="customer-dashboard-grid">
                <div>
                    <p class="text-muted"><strong>Destino:</strong> Maldivas</p>
                </div>
                <div>
                    <p class="text-muted"><strong>Datas:</strong> 12 Ago 2026 - 19 Ago 2026</p>
                </div>
                <div>
                    <p class="text-muted"><strong>Viajantes:</strong> 2 viajantes</p>
                </div>
            </div>

            <div class="customer-dashboard-grid">
                <div>
                    <p class="text-muted"><strong>Alojamento:</strong> Resort 5 estrelas</p>
                </div>
                <div>
                    <p class="text-muted"><strong>Regime:</strong> Pequeno-almoço e transfer incluídos</p>
                </div>
                <div>
                    <p class="text-muted"><strong>Estado:</strong> Reserva confirmada</p>
                </div>
            </div>

            <div class="surface-block">
                <div class="flow">
                    <span class="section-title__eyebrow">Resumo</span>
                    <p class="text-muted">A tua reserva encontra-se confirmada. Nesta área poderás mais tarde acompanhar pagamentos, documentos e atualizações relevantes.</p>
                </div>
            </div>

            <div class="actions-row">
                <a class="btn btn-primary" href="#">Transferir comprovativo</a>
                <a class="btn btn-secondary" href="#">Contactar apoio</a>
                <a class="btn btn-ghost" href="#">Ver política de cancelamento</a>
            </div>

            
        </div>
    </div>
</div>