<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
boolean aboutAuth = Boolean.TRUE.equals(session.getAttribute("auth"));
String aboutUserType = session.getAttribute("userType") != null ? String.valueOf(session.getAttribute("userType")) : "";
boolean aboutCliente = aboutAuth && "cliente".equals(aboutUserType);
boolean aboutStaff = aboutAuth && "staff".equals(aboutUserType);
String aboutCtx = request.getContextPath();
%>

<div class="public-page public-page--about">
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <div class="public-page-hero">
                <div class="public-page-hero__main">
                    <span class="public-page-header__eyebrow">Sobre nós</span>
                    <h1 class="public-page-header__title">Uma plataforma pensada para simplificar a descoberta de viagens</h1>
                    <p class="public-page-header__lead">O TravelExplorer foi criado para ajudar cada utilizador a explorar destinos, comparar propostas e preparar futuras reservas de forma clara, organizada e intuitiva.</p>
                    <p class="public-page-hero__text">Combinamos uma experiência visual cuidada com um fluxo de pesquisa progressivo, para que possas planear viagens com confiança — desde a inspiração inicial até à escolha do pacote ideal.</p>
                    <div class="public-page-hero__actions">
                        <% if (aboutCliente) { %>
                        <a class="btn btn-primary" href="<%= aboutCtx %>/index.jsp?page=customer-dashboard">Área de cliente</a>
                        <% } else if (aboutStaff) { %>
                        <a class="btn btn-primary" href="<%= aboutCtx %>/index.jsp?page=staff-dashboard">Área staff</a>
                        <% } else { %>
                        <a class="btn btn-primary" href="<%= aboutCtx %>/index.jsp?page=register">Criar conta</a>
                        <% } %>
                    </div>
                </div>
                <aside class="public-info-card">
                    <span class="public-info-card__eyebrow">Plataforma</span>
                    <h2 class="public-info-card__title">O que o utilizador pode fazer</h2>
                    <ul class="public-info-card__list">
                        <li>Explorar destinos e ideias de viagem</li>
                        <li>Comparar propostas com contexto visual e preço base</li>
                        <li>Consultar ofertas criadas pela equipa</li>
                        <li>Acompanhar futuras reservas na área de cliente</li>
                    </ul>
                </aside>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--accent public-section--balanced">
        <div class="container">
            <header class="public-section-intro">
                <span class="public-page-header__eyebrow">Valores</span>
                <h2 class="public-section-intro__title">Clareza, inspiração e confiança em cada passo</h2>
                <p class="public-section-intro__lead">O TravelExplorer evolui para integrar pesquisa real, reservas e gestão — mantendo sempre uma experiência pública simples e premium.</p>
            </header>

            <div class="public-values-grid">
                <article class="public-value-card">
                    <h3>Descoberta guiada</h3>
                    <p>Destinos e estilos de viagem apresentados de forma visual e fácil de comparar.</p>
                </article>
                <article class="public-value-card">
                    <h3>Propostas da equipa</h3>
                    <p>Ofertas criadas internamente com preço base e informação essencial visível.</p>
                </article>
                <article class="public-value-card">
                    <h3>Preparado para crescer</h3>
                    <p>Estrutura pronta para reservas, contas de cliente e áreas internas de gestão.</p>
                </article>
            </div>
        </div>
    </section>

    <% if (!aboutAuth) { %>
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/public/public_cta_banner.jsp">
                <jsp:param name="title" value="Pronto para começar a explorar?" />
                <jsp:param name="text" value="Descobre ofertas, inspira-te com destinos e prepara a tua futura experiência completa no TravelExplorer." />
                <jsp:param name="href" value="/index.jsp?page=register" />
                <jsp:param name="buttonText" value="Criar conta" />
            </jsp:include>
        </div>
    </section>
    <% } else if (aboutCliente) { %>
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/public/public_cta_banner.jsp">
                <jsp:param name="title" value="Acompanha as tuas reservas" />
                <jsp:param name="text" value="Acede à tua área de cliente para acompanhares as tuas reservas e ofertas guardadas." />
                <jsp:param name="href" value="/index.jsp?page=customer-dashboard" />
                <jsp:param name="buttonText" value="Área de cliente" />
            </jsp:include>
        </div>
    </section>
    <% } %>
</div>
