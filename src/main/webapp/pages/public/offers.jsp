<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="public-page">
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Ofertas" />
                <jsp:param name="heading" value="Encontra a oferta certa para a tua próxima viagem" />
                <jsp:param name="description" value="Explora uma seleção inicial de ofertas públicas com vários estilos de viagem, destinos e preços. Esta página será ligada mais tarde ao sistema real de pesquisa." />
            </jsp:include>

            <div class="public-search-box" style="margin-top: 2rem;">
                <form class="public-search-box__form" action="#" method="get">
                    <div class="public-search-box__field">
                        <label class="public-search-box__label" for="offersOrigin">Origem</label>
                        <input class="public-search-box__control" type="text" id="offersOrigin" name="origin" placeholder="Ex.: Porto">
                    </div>

                    <div class="public-search-box__field">
                        <label class="public-search-box__label" for="offersDestination">Destino</label>
                        <input class="public-search-box__control" type="text" id="offersDestination" name="destination" placeholder="Ex.: Roma">
                    </div>

                    <div class="public-search-box__field">
                        <label class="public-search-box__label" for="offersDate">Data</label>
                        <input class="public-search-box__control" type="date" id="offersDate" name="date">
                    </div>

                    <div class="public-search-box__field">
                        <label class="public-search-box__label" for="offersBudget">Preço máximo</label>
                        <select class="public-search-box__control" id="offersBudget" name="budget">
                            <option value="">Sem limite</option>
                            <option value="500">Até 500€</option>
                            <option value="1000">Até 1000€</option>
                            <option value="1500">Até 1500€</option>
                            <option value="2000">Até 2000€</option>
                        </select>
                    </div>

                    <button class="btn btn-accent public-search-box__action" type="submit">
                        Filtrar ofertas
                    </button>

                    
                </form>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <div class="cards-grid">
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="image" value="/assets/img/offers/offer-1.jpg" />
                    <jsp:param name="alt" value="Praia tropical com bangalôs sobre a água" />
                    <jsp:param name="tag1" value="Praia" />
                    <jsp:param name="tag2" value="7 noites" />
                    <jsp:param name="title" value="Maldivas Premium" />
                    <jsp:param name="origin" value="Porto" />
                    <jsp:param name="destination" value="Maldivas" />
                    <jsp:param name="extra" value="Transfer incluído" />
                    <jsp:param name="description" value="Uma viagem focada em descanso, mar cristalino e uma experiência exclusiva." />
                    <jsp:param name="price" value="Desde 1.250€" />
                </jsp:include>

                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="image" value="/assets/img/offers/offer-2.jpg" />
                    <jsp:param name="alt" value="Vista urbana europeia com edifícios históricos" />
                    <jsp:param name="tag1" value="Cidade" />
                    <jsp:param name="tag2" value="4 noites" />
                    <jsp:param name="title" value="Roma Essencial" />
                    <jsp:param name="origin" value="Lisboa" />
                    <jsp:param name="destination" value="Roma" />
                    <jsp:param name="extra" value="Hotel central" />
                    <jsp:param name="description" value="Ideal para descobrir monumentos, gastronomia e o lado clássico da cidade." />
                    <jsp:param name="price" value="Desde 720€" />
                </jsp:include>

                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="image" value="/assets/img/offers/offer-3.jpg" />
                    <jsp:param name="alt" value="Paisagem natural de montanha com lago" />
                    <jsp:param name="tag1" value="Natureza" />
                    <jsp:param name="tag2" value="5 noites" />
                    <jsp:param name="title" value="Suíça Escape" />
                    <jsp:param name="origin" value="Madrid" />
                    <jsp:param name="destination" value="Zurique" />
                    <jsp:param name="extra" value="Paisagens alpinas" />
                    <jsp:param name="description" value="Uma opção perfeita para quem procura tranquilidade, vistas incríveis e ar puro." />
                    <jsp:param name="price" value="Desde 940€" />
                </jsp:include>

                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="image" value="/assets/img/offers/offer-4.jpg" />
                    <jsp:param name="alt" value="Praia e cidade costeira ao pôr do sol" />
                    <jsp:param name="tag1" value="Verão" />
                    <jsp:param name="tag2" value="6 noites" />
                    <jsp:param name="title" value="Dubrovnik Sun Trip" />
                    <jsp:param name="origin" value="Porto" />
                    <jsp:param name="destination" value="Croácia" />
                    <jsp:param name="extra" value="Pequeno-almoço" />
                    <jsp:param name="description" value="Sol, mar e uma cidade costeira cheia de charme para umas férias completas." />
                    <jsp:param name="price" value="Desde 810€" />
                </jsp:include>

                
            </div>
        </div>
    </section>
</div>