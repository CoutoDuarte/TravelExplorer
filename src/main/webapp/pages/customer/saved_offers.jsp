<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<style>
    .saved-offers-grid {
        align-items: start;
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .saved-offers-grid .card {
        height: auto;
        align-self: start;
    }

    @media (max-width: 900px) {
        .saved-offers-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Guardados" />
        <jsp:param name="heading" value="Ofertas guardadas" />
        <jsp:param name="description" value="Consulta rapidamente as ofertas que guardaste para comparar ou rever mais tarde." />
    </jsp:include>

    <div class="customer-dashboard-grid saved-offers-grid">
        <jsp:include page="/components/public/public_offer_card.jsp">
            <jsp:param name="image" value="/assets/img/offers/offer-1.jpg" />
            <jsp:param name="alt" value="Praia tropical com mar azul" />
            <jsp:param name="tag1" value="Praia" />
            <jsp:param name="tag2" value="7 dias" />
            <jsp:param name="title" value="Maldivas Escape" />
            <jsp:param name="origin" value="Porto" />
            <jsp:param name="destination" value="Maldivas" />
            <jsp:param name="extra" value="Hotel incluído" />
            <jsp:param name="description" value="Uma proposta pensada para descanso, paisagens incríveis e uma experiência premium." />
            <jsp:param name="price" value="Desde 1.250€" />
        </jsp:include>

        <jsp:include page="/components/public/public_offer_card.jsp">
            <jsp:param name="image" value="/assets/img/offers/offer-2.jpg" />
            <jsp:param name="alt" value="Cidade europeia iluminada ao final da tarde" />
            <jsp:param name="tag1" value="Cidade" />
            <jsp:param name="tag2" value="4 dias" />
            <jsp:param name="title" value="Paris City Lights" />
            <jsp:param name="origin" value="Lisboa" />
            <jsp:param name="destination" value="Paris" />
            <jsp:param name="extra" value="Pequeno-almoço" />
            <jsp:param name="description" value="Ideal para uma escapadinha elegante com cultura, gastronomia e passeios memoráveis." />
            <jsp:param name="price" value="Desde 690€" />
        </jsp:include>
    </div>

    
</div>