<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
boolean homeAuth = Boolean.TRUE.equals(session.getAttribute("auth"));
String homeUserType = session.getAttribute("userType") != null ? String.valueOf(session.getAttribute("userType")) : "";
boolean homeCliente = homeAuth && "cliente".equals(homeUserType);
boolean homeStaff = homeAuth && "staff".equals(homeUserType);
String homeCtx = request.getContextPath();
%>
<div class="public-page">
    <section class="public-page__section public-page__section--hero hero-studio" id="hero-studio">
        <div class="container hero-studio__container">
            <div class="hero-studio__top">
                <div class="hero-studio__copy">
                    <span class="public-hero__eyebrow">Explora o mundo com confiança</span>
                    <h1 class="public-hero__title hero-studio__title">
                        Encontra a tua próxima viagem com o TravelExplorer
                    </h1>
                    <p class="public-hero__text hero-studio__text">
                        Descobre destinos, compara voos e escolhe o alojamento ideal numa experiência
                        pensada para viajar com calma e estilo.
                    </p>
                    <div class="public-hero__actions">
                        <a class="btn btn-primary" href="<%= homeCtx %>/index.jsp?page=offers">
                            Ver ofertas
                        </a>
                        <% if (homeCliente) { %>
                        <a class="btn btn-secondary" href="<%= homeCtx %>/index.jsp?page=customer-dashboard">Área de cliente</a>
                        <% } else if (homeStaff) { %>
                        <a class="btn btn-secondary" href="<%= homeCtx %>/index.jsp?page=staff-dashboard">Área staff</a>
                        <% } else { %>
                        <a class="btn btn-secondary" href="<%= homeCtx %>/index.jsp?page=register">Criar conta</a>
                        <% } %>
                    </div>
                    <div class="public-hero__highlights hero-studio__highlights">
                        <span class="public-hero__highlight">Ofertas selecionadas</span>
                        <span class="public-hero__highlight">Destinos populares</span>
                        <span class="public-hero__highlight">Pacotes flexíveis</span>
                    </div>
                </div>
            </div>

            <%@ include file="/components/public/public_hero_search.jspf" %>
        </div>
    </section>

    <section class="public-page__section public-page__section--soft home-ideas">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Ofertas em destaque" />
                <jsp:param name="heading" value="Ideias de viagem para começar já a explorar" />
                <jsp:param name="description" value="Inspira-te com alguns dos destinos mais procurados." />
                <jsp:param name="extraClass" value="section-title--home-ideas" />
            </jsp:include>

            <div class="cards-grid home-ideas__grid">
                <jsp:include page="/components/public/public_offer_card.jsp">
                    <jsp:param name="gradientOnly" value="true" />
                    <jsp:param name="gradientSeed" value="1" />
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
                    <jsp:param name="gradientOnly" value="true" />
                    <jsp:param name="gradientSeed" value="2" />
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
                    <jsp:param name="gradientOnly" value="true" />
                    <jsp:param name="gradientSeed" value="3" />
                    <jsp:param name="tag1" value="Natureza" />
                    <jsp:param name="tag2" value="5 dias" />
                    <jsp:param name="title" value="Alpes Adventure" />
                    <jsp:param name="origin" value="Madrid" />
                    <jsp:param name="destination" value="Suíça" />
                    <jsp:param name="extra" value="Experiência guiada" />
                    <jsp:param name="description" value="Uma opção para quem procura paisagens naturais, aventura e momentos únicos ao ar livre." />
                    <jsp:param name="price" value="Desde 940€" />
                </jsp:include>
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
                    <jsp:param name="title" value="Santorini" />
                    <jsp:param name="text" value="Paisagens inesquecíveis e ambiente mediterrânico." />
                </jsp:include>
                <jsp:include page="/components/public/public_category_card.jsp">
                    <jsp:param name="title" value="Bali" />
                    <jsp:param name="text" value="Relaxamento, cultura e experiências tropicais." />
                </jsp:include>
                <jsp:include page="/components/public/public_category_card.jsp">
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
