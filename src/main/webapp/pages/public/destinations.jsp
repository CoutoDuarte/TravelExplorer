<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="public-page">
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Destinos" />
                <jsp:param name="heading" value="Inspira-te com destinos para a tua próxima viagem" />
                <jsp:param name="description" value="Explora sugestões de destinos, estilos de viagem e ideias para encontrares a experiência certa para ti." />
            </jsp:include>

            <div class="split-layout split-layout--content-start" style="margin-top: 2rem; align-items: stretch;">
                <div class="surface-block surface-block-lg">
                    <div class="flow">
                        <span class="section-title__eyebrow">Explorar possibilidades</span>
                        <h2 style="font-size: 1.5rem; color: var(--color-primary);">
                            Descobre ambientes, ritmos e experiências diferentes
                        </h2>
                        <p class="text-muted">
                            A página de destinos ajuda o utilizador a explorar ideias antes de comparar ofertas. Aqui o foco é inspirar, mostrar variedade e orientar a navegação para o tipo de viagem mais interessante.
                        </p>

                        <div class="actions-row">
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/index.jsp?page=offers">Ver ofertas</a>
                            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=register">Criar conta</a>
                        </div>
                    </div>
                </div>

                <div class="surface-block surface-block-lg">
                    <div class="flow">
                        <span class="section-title__eyebrow">O que podes encontrar</span>
                        <p class="text-muted"><strong>Praia:</strong> relaxamento, calor, mar e escapadinhas tropicais.</p>
                        <p class="text-muted"><strong>Cidade:</strong> cultura, gastronomia, monumentos e ritmo urbano.</p>
                        <p class="text-muted"><strong>Natureza:</strong> montanha, tranquilidade, paisagens e aventura.</p>
                        <p class="text-muted"><strong>Experiências premium:</strong> estadias exclusivas e viagens mais completas.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--accent">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Em destaque" />
                <jsp:param name="heading" value="Alguns destinos populares para começar a explorar" />
                <jsp:param name="description" value="Uma seleção visual de destinos pensada para inspirar e orientar o utilizador para diferentes estilos de viagem." />
            </jsp:include>

            <div class="cards-grid" style="margin-top: 2rem;">
                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-1.jpg" />
                    <jsp:param name="title" value="Santorini" />
                    <jsp:param name="text" value="Paisagens inesquecíveis, branco mediterrânico e um ambiente sofisticado." />
                </jsp:include>

                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-2.jpg" />
                    <jsp:param name="title" value="Bali" />
                    <jsp:param name="text" value="Relaxamento, natureza tropical e experiências culturais marcantes." />
                </jsp:include>

                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-3.jpg" />
                    <jsp:param name="title" value="Tóquio" />
                    <jsp:param name="text" value="Energia urbana, tecnologia, tradição e uma atmosfera única." />
                </jsp:include>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Estilos de viagem" />
                <jsp:param name="heading" value="Escolhe o tipo de experiência que mais combina contigo" />
                <jsp:param name="description" value="Esta secção reforça a ideia de descoberta e pode mais tarde evoluir para categorias dinâmicas ligadas a pesquisa real." />
            </jsp:include>

            <div class="cards-grid" style="margin-top: 2rem;">
                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-4.jpg" />
                    <jsp:param name="title" value="Praia" />
                    <jsp:param name="text" value="Viagens para relaxar, desfrutar do sol e aproveitar ambientes costeiros." />
                </jsp:include>

                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-5.jpg" />
                    <jsp:param name="title" value="Cidade" />
                    <jsp:param name="text" value="Destinos urbanos com cultura, gastronomia e experiências memoráveis." />
                </jsp:include>

                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-6.jpg" />
                    <jsp:param name="title" value="Natureza" />
                    <jsp:param name="text" value="Paisagens naturais, montanhas, lagos e momentos de tranquilidade." />
                </jsp:include>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/public/public_cta_banner.jsp">
                <jsp:param name="title" value="Queres transformar inspiração em viagem?" />
                <jsp:param name="text" value="Explora as ofertas disponíveis e encontra uma proposta que combine com o destino e o estilo de viagem que procuras." />
                <jsp:param name="href" value="/index.jsp?page=offers" />
                <jsp:param name="buttonText" value="Explorar ofertas" />
            </jsp:include>
        </div>
    </section>
</div>