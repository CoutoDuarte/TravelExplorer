<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="Connection.CRUD.ClienteCRUD,Connection.CRUD.ReservaCRUD,Connection.CRUD.PacoteCRUD,Connection.CRUD.PromocaoCRUD" %>
<%
ClienteCRUD clienteCRUDDash = new ClienteCRUD();
ReservaCRUD reservaCRUDDash = new ReservaCRUD();
PacoteCRUD pacoteCRUDDash = new PacoteCRUD();
PromocaoCRUD promocaoCRUDDash = new PromocaoCRUD();
int cntReservasAtivas = reservaCRUDDash.countAtivas();
int cntClientes = clienteCRUDDash.countAll();
int cntPacotes = pacoteCRUDDash.countAll();
int cntPromoAtivas = promocaoCRUDDash.countAtivas();
%>

<div class="flow staff-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Dashboard" />
        <jsp:param name="heading" value="Painel principal da área staff" />
        <jsp:param name="description" value="Indicadores em tempo real com base nos registos da base de dados." />
    </jsp:include>

    <div class="staff-dashboard-grid">
        <div class="surface-block staff-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Reservas</span>
                <h2 style="font-size: 1.25rem;"><%= cntReservasAtivas %> reservas ativas</h2>
                <p class="text-muted">Reservas que não estão canceladas, concluídas ou finalizadas.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-reservations">Ver reservas</a>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Clientes</span>
                <h2 style="font-size: 1.25rem;"><%= cntClientes %> clientes registados</h2>
                <p class="text-muted">Total de contas de cliente na plataforma.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-clients">Ver clientes</a>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Ofertas</span>
                <h2 style="font-size: 1.25rem;"><%= cntPacotes %> pacotes</h2>
                <p class="text-muted">Ofertas e pacotes comerciais disponíveis para gestão.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-offers">Ver ofertas e pacotes</a>
            </div>
        </div>

        <div class="surface-block staff-summary-card">
            <div class="flow">
                <span class="section-title__eyebrow">Promoções</span>
                <h2 style="font-size: 1.25rem;"><%= cntPromoAtivas %> promoções ativas</h2>
                <p class="text-muted">Campanhas com estado ativo ou publicado.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-promotions">Ver promoções</a>
            </div>
        </div>
    </div>
</div>
