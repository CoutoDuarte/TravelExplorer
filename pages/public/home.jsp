<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="public-page">
    <section class="public-page__section public-page__section--hero">
        <div class="container">
            <div class="public-hero">
                <div class="public-hero__content">
                    <span class="public-hero__eyebrow">Explora o mundo com confiança</span>

                    <h1 class="public-hero__title">
                        Encontra a tua próxima viagem com o TravelExplorer
                    </h1>

                    <p class="public-hero__text">
                        Descobre ofertas, compara destinos e encontra pacotes pensados para férias,
                        escapadinhas ou viagens especiais, tudo numa experiência simples e moderna.
                    </p>

                    <div class="public-hero__actions">
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/index.jsp?page=offers">
                            Ver ofertas
                        </a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=register">
                            Criar conta
                        </a>
                    </div>

                    <div class="public-hero__highlights">
                        <span class="public-hero__highlight">Ofertas selecionadas</span>
                        <span class="public-hero__highlight">Destinos populares</span>
                        <span class="public-hero__highlight">Pacotes flexíveis</span>
                    </div>

                    <%@ include file="/components/public/public_hero_search.jspf" %>
                </div>

                <div class="public-hero__media">
                    <div class="public-hero__image"></div>

                    <div class="public-hero__floating-card">
                        <span class="public-hero__floating-label">Em destaque</span>
                        <div class="public-hero__floating-title">Escapadinha em Santorini</div>
                        <p class="public-hero__floating-text">
                            Uma sugestão visual de campanha para dar vida à homepage pública.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <div class="public-stats">
                <div class="public-stat">
                    <div class="public-stat__value">120+</div>
                    <div class="public-stat__label">Destinos disponíveis</div>
                </div>

                <div class="public-stat">
                    <div class="public-stat__value">350+</div>
                    <div class="public-stat__label">Ofertas ativas</div>
                </div>

                <div class="public-stat">
                    <div class="public-stat__value">24/7</div>
                    <div class="public-stat__label">Experiência sempre acessível</div>
                </div>

                <%-- Duarte: estes números podem vir depois de métricas reais da base de dados ou da API. --%>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Ofertas em destaque" />
                <jsp:param name="heading" value="Ideias de viagem para começar já a explorar" />
                <jsp:param name="description" value="Uma seleção inicial de cartões estáticos para representar as futuras ofertas públicas da plataforma." />
            </jsp:include>

            <div class="cards-grid" style="margin-top: 2rem;">
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

                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="image" value="/assets/img/offers/offer-3.jpg" />
                    <jsp:param name="alt" value="Paisagem de montanha com lago e trilhos" />
                    <jsp:param name="tag1" value="Natureza" />
                    <jsp:param name="tag2" value="5 dias" />
                    <jsp:param name="title" value="Alpes Adventure" />
                    <jsp:param name="origin" value="Madrid" />
                    <jsp:param name="destination" value="Suíça" />
                    <jsp:param name="extra" value="Experiência guiada" />
                    <jsp:param name="description" value="Uma opção para quem procura paisagens naturais, aventura e momentos únicos ao ar livre." />
                    <jsp:param name="price" value="Desde 940€" />
                </jsp:include>

                <%-- Duarte: estes cartões poderão mais tarde ser gerados por ciclo com dados reais vindos do backend. --%>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--accent">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Destinos populares" />
                <jsp:param name="heading" value="Inspira-te com alguns dos destinos mais procurados" />
                <jsp:param name="description" value="Esta secção serve para destacar destinos e ajudar o utilizador a descobrir novas ideias antes de procurar uma oferta." />
            </jsp:include>

            <div class="cards-grid" style="margin-top: 2rem;">
                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-1.jpg" />
                    <jsp:param name="title" value="Santorini" />
                    <jsp:param name="text" value="Paisagens inesquecíveis e ambiente mediterrânico." />
                </jsp:include>

                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-2.jpg" />
                    <jsp:param name="title" value="Bali" />
                    <jsp:param name="text" value="Relaxamento, cultura e experiências tropicais." />
                </jsp:include>

                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-3.jpg" />
                    <jsp:param name="title" value="Tóquio" />
                    <jsp:param name="text" value="Modernidade, energia urbana e tradição." />
                </jsp:include>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/public/public_cta_banner.jsp">
                <jsp:param name="title" value="Guarda as tuas ofertas favoritas e acompanha as tuas reservas" />
                <jsp:param name="text" value="Cria a tua conta para aceder futuramente à tua área pessoal, guardar ofertas e acompanhar o estado das reservas." />
                <jsp:param name="href" value="/index.jsp?page=register" />
                <jsp:param name="buttonText" value="Começar agora" />
            </jsp:include>
        </div>
    </section>
</div>