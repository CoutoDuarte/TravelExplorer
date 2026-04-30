<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Reservas" />
        <jsp:param name="heading" value="As minhas reservas" />
        <jsp:param name="description" value="Consulta rapidamente as tuas reservas atuais e acompanha o respetivo estado." />
    </jsp:include>

    <div class="customer-dashboard-grid">
        <jsp:include page="/components/customer/reservation_card.jsp">
            <jsp:param name="status" value="Ativa" />
            <jsp:param name="title" value="Maldivas Premium" />
            <jsp:param name="reference" value="RES-1001" />
            <jsp:param name="destination" value="Maldivas" />
            <jsp:param name="dates" value="12 Ago 2026 - 19 Ago 2026" />
            <jsp:param name="travelers" value="2 viajantes" />
            <jsp:param name="statusText" value="Reserva confirmada" />
        </jsp:include>

        <jsp:include page="/components/customer/reservation_card.jsp">
            <jsp:param name="status" value="Em preparação" />
            <jsp:param name="title" value="Roma Essencial" />
            <jsp:param name="reference" value="RES-1002" />
            <jsp:param name="destination" value="Roma" />
            <jsp:param name="dates" value="03 Set 2026 - 07 Set 2026" />
            <jsp:param name="travelers" value="1 viajante" />
            <jsp:param name="statusText" value="A aguardar confirmação final" />
        </jsp:include>
    </div>

    
    
</div>
