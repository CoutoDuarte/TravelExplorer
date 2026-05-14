<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,Connection.Classes.Pacote,Connection.CRUD.PacoteCRUD" %>
<%
PacoteCRUD pacoteCRUDPublic = new PacoteCRUD();
List<Pacote> listaOfertas = pacoteCRUDPublic.findAll();
java.text.DecimalFormatSymbols symO = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
symO.setDecimalSeparator(',');
symO.setGroupingSeparator(' ');
java.text.DecimalFormat dfOferta = new java.text.DecimalFormat("#,##0.00", symO);
%>

<div class="public-page">
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Ofertas" />
                <jsp:param name="heading" value="Encontra a oferta certa para a tua próxima viagem" />
                <jsp:param name="description" value="Explora os pacotes disponíveis publicados pela agência. Os preços base e as condições gerais são indicados em cada cartão." />
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
            <% if (listaOfertas == null || listaOfertas.isEmpty()) { %>
            <p class="text-muted">Sem ofertas disponíveis de momento.</p>
            <% } else { %>
            <div class="cards-grid">
                <% for (Pacote op : listaOfertas) {
                    int imgN = (op.getIdPacote() % 4) + 1;
                    String imgPath = "/assets/img/offers/offer-" + imgN + ".jpg";
                    String titulo = op.getNome() != null ? op.getNome() : "Pacote";
                    String desc = op.getDescricao() != null ? op.getDescricao() : "";
                    if (desc.length() > 160) {
                        desc = desc.substring(0, 160) + "…";
                    }
                    String precoTxt = "Desde " + dfOferta.format(op.getPrecoBase()) + " €";
                    String tag2 = op.getNumAdultos() + " adultos";
                    if (op.getNumCriancas() > 0) {
                        tag2 = tag2 + ", " + op.getNumCriancas() + " crianças";
                    }
                    String extraRef = "Ref. " + op.getIdPacote();
                    String detailHref = "offer-details&idPacote=" + op.getIdPacote();
                %>
                <article class="card">
                    <div class="card__media">
                        <img src="${pageContext.request.contextPath}<%= imgPath %>" alt="<%= titulo.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;") %>">
                    </div>
                    <div class="card__body">
                        <div class="card__meta">
                            <span class="card__tag">Pacote</span>
                            <span class="card__tag"><%= tag2 %></span>
                        </div>
                        <h3 class="card__title"><%= titulo %></h3>
                        <div class="offer-card__meta-line">
                            <span>—</span>
                            <span>—</span>
                            <span><%= extraRef %></span>
                        </div>
                        <p class="offer-card__description"><%= desc %></p>
                        <div class="card__footer">
                            <span class="card__price"><%= precoTxt %></span>
                            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=<%= detailHref %>">Ver detalhe</a>
                        </div>
                    </div>
                </article>
                <% } %>
            </div>
            <% } %>
        </div>
    </section>
</div>
