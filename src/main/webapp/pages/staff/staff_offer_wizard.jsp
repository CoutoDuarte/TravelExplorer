<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
request.setAttribute("teWizardMode", "staff");
request.setAttribute("teWizardAuthorized", Boolean.TRUE);
request.setAttribute("teGuardarUrl", request.getContextPath() + "/guardar-oferta");
String offersListUrl = request.getContextPath() + "/index.jsp?page=staff-offers&tab=ofertas&success=offer-created";
String publicCss = request.getContextPath() + "/assets/css/public.css";
String staffCss = request.getContextPath() + "/assets/css/staff.css";
%>

<link rel="stylesheet" href="<%= publicCss %>">
<link rel="stylesheet" href="<%= staffCss %>">

<div class="staff-shell staff-offer-wizard-page public-page public-page--wizard">
    <div class="flow">
        <div class="staff-offers-page-header">
            <div class="section-title">
                <span class="section-title__eyebrow">Nova oferta</span>
                <h1 class="section-title__heading">Criar oferta pública</h1>
                <p class="section-title__description">Define origem, destino, datas e componentes da viagem. A oferta ficará disponível na área pública sem criar reserva de cliente.</p>
            </div>
            <div class="actions-row" style="flex-shrink: 0;">
                <a class="btn btn-secondary" href="<%= request.getContextPath() %>/index.jsp?page=staff-offers&amp;tab=ofertas">Voltar à gestão</a>
            </div>
        </div>

        <div class="surface-block surface-block-lg staff-offer-wizard__panel">
            <%@ include file="/components/public/public_hero_search.jspf" %>
        </div>
    </div>
</div>

<script>
window.TE_STAFF_OFFER_SUCCESS_URL = "<%= offersListUrl %>";
</script>
<script src="${pageContext.request.contextPath}/assets/js/public.js"></script>
