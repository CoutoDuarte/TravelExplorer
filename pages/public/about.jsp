<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="public-page">
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <div class="split-layout split-layout--content-start">
                <div class="content-stack">
                    <jsp:include page="/components/shared/section_title.jsp">
                        <jsp:param name="eyebrow" value="Sobre nós" />
                        <jsp:param name="heading" value="Uma plataforma pensada para tornar a descoberta de viagens mais simples" />
                        <jsp:param name="description" value="O TravelExplorer foi desenhado para oferecer uma experiência moderna, clara e organizada, ajudando cada utilizador a explorar destinos, comparar ofertas e acompanhar futuras reservas." />
                    </jsp:include>

                    <div class="flow">
                        <p>
                            Nesta fase do projeto, esta página funciona como apresentação institucional da plataforma,
                            explicando a visão do TravelExplorer e o tipo de experiência que queremos entregar no lado público.
                        </p>
                        <p>
                            O objetivo é combinar uma navegação intuitiva com uma estrutura preparada para crescer,
                            permitindo no futuro integrar pesquisa real, reservas, contas de cliente e áreas internas de gestão.
                        </p>
                    </div>

                    <div class="actions-row">
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/index.jsp?page=offers">
                            Explorar ofertas
                        </a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=register">
                            Criar conta
                        </a>
                    </div>
                </div>

                <div class="surface-block surface-block-xl content-stack">
                    <span class="section-title__eyebrow">O que o utilizador pode fazer</span>

                    <div class="flow">
                        <p><strong>Explorar destinos:</strong> navegar por sugestões e descobrir ideias de viagem.</p>
                        <p><strong>Comparar ofertas:</strong> visualizar propostas com contexto visual e preço base.</p>
                        <p><strong>Guardar favoritos:</strong> no futuro, cada cliente poderá guardar ofertas preferidas.</p>
                        <p><strong>Acompanhar reservas:</strong> a área de cliente irá permitir consultar o estado das reservas.</p>
                    </div>

                    <%-- Duarte: esta área poderá mais tarde apresentar conteúdos institucionais dinâmicos vindos da configuração global da plataforma. --%>
                </div>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--accent">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Destinos" />
                <jsp:param name="heading" value="Alguns estilos de viagem que o TravelExplorer poderá destacar" />
                <jsp:param name="description" value="Esta secção ajuda a reforçar o lado inspiracional da plataforma pública e pode mais tarde tornar-se dinâmica." />
            </jsp:include>

            <div class="cards-grid" style="margin-top: 2rem;">
                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-4.jpg" />
                    <jsp:param name="title" value="Praia" />
                    <jsp:param name="text" value="Escapadinhas relaxantes em destinos costeiros e tropicais." />
                </jsp:include>

                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-5.jpg" />
                    <jsp:param name="title" value="Cidade" />
                    <jsp:param name="text" value="Experiências urbanas com cultura, gastronomia e património." />
                </jsp:include>

                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="image" value="/assets/img/destinations/destination-6.jpg" />
                    <jsp:param name="title" value="Natureza" />
                    <jsp:param name="text" value="Paisagens tranquilas, montanha, aventura e contacto com o exterior." />
                </jsp:include>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/public/public_cta_banner.jsp">
                <jsp:param name="title" value="Pronto para começar a explorar?" />
                <jsp:param name="text" value="Descobre ofertas, inspira-te com destinos e prepara a tua futura experiência completa no TravelExplorer." />
                <jsp:param name="href" value="/index.jsp?page=offers" />
                <jsp:param name="buttonText" value="Ver ofertas" />
            </jsp:include>
        </div>
    </section>
</div>