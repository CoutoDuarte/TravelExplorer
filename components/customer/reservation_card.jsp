<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<article class="surface-block customer-summary-card">
    <div class="flow">
        <div class="actions-row" style="justify-content: space-between; align-items: flex-start;">
            <div class="flow" style="gap: 0.45rem;">
                <span class="section-title__eyebrow"><%= request.getParameter("status") != null ? request.getParameter("status") : "" %></span>
                <h2 style="font-size: 1.2rem;"><%= request.getParameter("title") != null ? request.getParameter("title") : "" %></h2>
            </div>

            <span class="card__tag"><%= request.getParameter("reference") != null ? request.getParameter("reference") : "" %></span>
        </div>

        <div class="flow" style="gap: 0.65rem;">
            <p class="text-muted"><strong>Destino:</strong> <%= request.getParameter("destination") != null ? request.getParameter("destination") : "" %></p>
            <p class="text-muted"><strong>Datas:</strong> <%= request.getParameter("dates") != null ? request.getParameter("dates") : "" %></p>
            <p class="text-muted"><strong>Viajantes:</strong> <%= request.getParameter("travelers") != null ? request.getParameter("travelers") : "" %></p>
            <p class="text-muted"><strong>Estado:</strong> <%= request.getParameter("statusText") != null ? request.getParameter("statusText") : "" %></p>
        </div>

        <div class="actions-row">
            <a class="btn btn-secondary" href="#">Ver detalhes</a>
        </div>
    </div>

    <%-- Duarte: este componente deverá mais tarde receber dados reais da reserva autenticada, incluindo ID, estado e datas. --%>
</article>