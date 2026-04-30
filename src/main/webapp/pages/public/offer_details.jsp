<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="public-page">
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <div class="split-layout split-layout--content-start">
                <div class="content-stack">
                    <div class="media-frame media-frame--hero">
                        <img src="${pageContext.request.contextPath}/assets/img/offers/offer-1.jpg" alt="Vista paradisíaca de resort nas Maldivas">
                    </div>
                </div>

                <div class="surface-block surface-block-xl content-stack">
                    <span class="section-title__eyebrow">Detalhe da oferta</span>

                    <div class="content-stack">
                        <h1>Maldivas Premium</h1>
                        <p class="text-muted">
                            Uma experiência exclusiva para quem procura tranquilidade, conforto e paisagens tropicais inesquecíveis.
                        </p>
                    </div>

                    <div class="actions-row">
                        <span class="card__tag">Praia</span>
                        <span class="card__tag">7 noites</span>
                        <span class="card__tag">Tudo incluído</span>
                    </div>

                    <div class="content-stack">
                        <div>
                            <strong>Origem:</strong> Porto
                        </div>
                        <div>
                            <strong>Destino:</strong> Maldivas
                        </div>
                        <div>
                            <strong>Duração:</strong> 7 noites / 8 dias
                        </div>
                        <div>
                            <strong>Alojamento:</strong> Resort 5 estrelas
                        </div>
                        <div>
                            <strong>Regime:</strong> Pequeno-almoço e transfer incluídos
                        </div>
                    </div>

                    <div class="surface-block">
                        <div class="content-stack">
                            <span class="text-muted">Preço base</span>
                            <div class="card__price" style="font-size: 2rem;">Desde 1.250€</div>
                            <p class="text-muted">
                                O preço apresentado é meramente ilustrativo nesta fase de frontend.
                            </p>
                        </div>
                    </div>

                    <div class="content-stack">
                        <h2 style="font-size: 1.4rem;">O que está incluído</h2>
                        <div class="flow">
                            <p>• Voos de ida e volta</p>
                            <p>• Estadia em resort selecionado</p>
                            <p>• Transfer aeroporto - hotel - aeroporto</p>
                            <p>• Apoio da agência durante o processo de reserva</p>
                        </div>
                    </div>

                    <div class="actions-row">
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/index.jsp?page=login">
                            Reservar agora
                        </a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=offers">
                            Voltar às ofertas
                        </a>
                    </div>

                    <p class="text-muted">
                        Para reservar esta oferta, o utilizador deverá iniciar sessão ou criar conta.
                    </p>

                    
                </div>
            </div>
        </div>
    </section>

    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Descrição" />
                <jsp:param name="heading" value="Uma viagem pensada para relaxar e aproveitar cada momento" />
                <jsp:param name="description" value="Esta página funciona como base visual para o detalhe de uma oferta. Mais tarde poderá mostrar informação dinâmica como condições, políticas de cancelamento, disponibilidade e serviços incluídos." />
            </jsp:include>

            <div class="surface-block surface-block-lg" style="margin-top: 2rem;">
                <div class="flow">
                    <p>
                        A oferta Maldivas Premium foi desenhada para utilizadores que procuram uma experiência calma,
                        confortável e memorável num destino de sonho.
                    </p>
                    <p>
                        O objetivo desta página é apresentar a oferta com mais contexto visual e comercial antes do
                        utilizador avançar para autenticação e futura reserva.
                    </p>
                    <p>
                        Nesta fase do projeto, o conteúdo é estático e serve apenas de base para integração futura.
                    </p>
                </div>
            </div>
        </div>
    </section>
</div>