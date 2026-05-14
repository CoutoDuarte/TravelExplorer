<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,Connection.Classes.Pacote,Connection.Classes.Viagens,Connection.CRUD.PacoteCRUD,Connection.CRUD.ViagemCRUD" %>
<%
String idPacoteStr = request.getParameter("idPacote");
Pacote detPacote = null;
boolean idEmFalta = idPacoteStr == null || idPacoteStr.trim().isEmpty();
if (!idEmFalta) {
    try {
        detPacote = new PacoteCRUD().findById(Integer.parseInt(idPacoteStr.trim()));
    } catch (NumberFormatException ignored) {
    }
}
List<Viagens> detViagens = detPacote != null ? new ViagemCRUD().findByPacote(detPacote.getIdPacote()) : java.util.Collections.emptyList();
String origemLinha = "—";
String destinoLinha = "—";
if (!detViagens.isEmpty()) {
    Viagens primeira = detViagens.get(0);
    if (primeira.getOrigem() != null) {
        origemLinha = primeira.getOrigem();
    }
    if (primeira.getDestino() != null) {
        destinoLinha = primeira.getDestino();
    }
}
java.text.DecimalFormatSymbols symD = new java.text.DecimalFormatSymbols(java.util.Locale.forLanguageTag("pt-PT"));
symD.setDecimalSeparator(',');
symD.setGroupingSeparator(' ');
java.text.DecimalFormat dfDet = new java.text.DecimalFormat("#,##0.00", symD);
int imgDet = 1;
if (detPacote != null) {
    imgDet = (detPacote.getIdPacote() % 4) + 1;
}
String imgDetPath = "/assets/img/offers/offer-" + imgDet + ".jpg";
%>

<div class="public-page">
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <% if (idEmFalta) { %>
            <div class="surface-block surface-block-xl content-stack">
                <h1>Detalhe da oferta</h1>
                <p class="text-muted">Para veres o detalhe de um pacote, escolhe primeiro uma oferta na listagem pública.</p>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/index.jsp?page=offers">Ir para ofertas</a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp" style="margin-left: 0.5rem;">Início</a>
            </div>
            <% } else if (detPacote == null) { %>
            <div class="surface-block surface-block-xl content-stack">
                <h1>Oferta não encontrada</h1>
                <p class="text-muted">O pacote pedido não existe ou deixou de estar disponível.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=offers">Voltar às ofertas</a>
            </div>
            <% } else {
                String nomeDet = detPacote.getNome() != null ? detPacote.getNome() : "Pacote";
                String descDet = detPacote.getDescricao() != null ? detPacote.getDescricao() : "";
            %>
            <div class="split-layout split-layout--content-start">
                <div class="content-stack">
                    <div class="media-frame media-frame--hero">
                        <img src="${pageContext.request.contextPath}<%= imgDetPath %>" alt="<%= nomeDet.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;") %>">
                    </div>
                </div>

                <div class="surface-block surface-block-xl content-stack">
                    <span class="section-title__eyebrow">Detalhe da oferta</span>

                    <div class="content-stack">
                        <h1><%= nomeDet %></h1>
                        <p class="text-muted"><%= descDet.length() > 400 ? descDet.substring(0, 400) + "…" : descDet %></p>
                    </div>

                    <div class="actions-row">
                        <span class="card__tag">Pacote</span>
                        <span class="card__tag"><%= detPacote.getNumAdultos() %> adultos</span>
                        <% if (detPacote.getNumCriancas() > 0) { %>
                        <span class="card__tag"><%= detPacote.getNumCriancas() %> crianças</span>
                        <% } %>
                    </div>

                    <div class="content-stack">
                        <div>
                            <strong>Origem (viagem associada):</strong> <%= origemLinha %>
                        </div>
                        <div>
                            <strong>Destino (viagem associada):</strong> <%= destinoLinha %>
                        </div>
                        <div>
                            <strong>Lotação indicada:</strong> <%= detPacote.getNumAdultos() %> adultos<% if (detPacote.getNumCriancas() > 0) { %>, <%= detPacote.getNumCriancas() %> crianças<% } %>
                        </div>
                    </div>

                    <div class="surface-block">
                        <div class="content-stack">
                            <span class="text-muted">Preço base</span>
                            <div class="card__price" style="font-size: 2rem;">Desde <%= dfDet.format(detPacote.getPrecoBase()) %> €</div>
                            <p class="text-muted">
                                Preço base do pacote. Condições finais podem variar consoante extras e disponibilidade.
                            </p>
                        </div>
                    </div>

                    <div class="content-stack">
                        <h2 style="font-size: 1.4rem;">Descrição completa</h2>
                        <div class="flow">
                            <p style="white-space: pre-wrap;"><%= descDet %></p>
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
            <% } %>
        </div>
    </section>

    <% if (detPacote != null) { %>
    <section class="public-page__section public-page__section--soft">
        <div class="container">
            <jsp:include page="/components/shared/section_title.jsp">
                <jsp:param name="eyebrow" value="Informação" />
                <jsp:param name="heading" value="Condições e próximos passos" />
                <jsp:param name="description" value="Consulta a descrição do pacote e contacta a agência para confirmar disponibilidade, datas e serviços incluídos." />
            </jsp:include>

            <div class="surface-block surface-block-lg" style="margin-top: 2rem;">
                <div class="flow">
                    <p>
                        Este pacote está registado na plataforma TravelExplorer. A equipa pode associar viagens, alojamentos e transportes
                        ao pacote na área interna de gestão.
                    </p>
                </div>
            </div>
        </div>
    </section>
    <% } %>
</div>
