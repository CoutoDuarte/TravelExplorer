<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<article class="card">
    <div class="card__media">
        <img
            src="${pageContext.request.contextPath}<%= request.getParameter("image") != null ? request.getParameter("image") : "" %>"
            alt="<%= request.getParameter("alt") != null ? request.getParameter("alt") : "" %>">
    </div>

    <div class="card__body">
        <div class="card__meta">
            <span class="card__tag"><%= request.getParameter("tag1") != null ? request.getParameter("tag1") : "" %></span>
            <span class="card__tag"><%= request.getParameter("tag2") != null ? request.getParameter("tag2") : "" %></span>
        </div>

        <h3 class="card__title"><%= request.getParameter("title") != null ? request.getParameter("title") : "" %></h3>

        <div class="offer-card__meta-line">
            <span><%= request.getParameter("origin") != null ? request.getParameter("origin") : "" %></span>
            <span><%= request.getParameter("destination") != null ? request.getParameter("destination") : "" %></span>
            <span><%= request.getParameter("extra") != null ? request.getParameter("extra") : "" %></span>
        </div>

        <p class="offer-card__description">
            <%= request.getParameter("description") != null ? request.getParameter("description") : "" %>
        </p>

        <div class="card__footer">
            <span class="card__price"><%= request.getParameter("price") != null ? request.getParameter("price") : "" %></span>
            <% String idPacoteCard = request.getParameter("idPacote");
               String detailPage = "offer-details";
               if (idPacoteCard != null && !idPacoteCard.trim().isEmpty()) {
                   detailPage = "offer-details&idPacote=" + idPacoteCard.trim();
               } %>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=<%= detailPage %>">
                Ver detalhe
            </a>
        </div>
    </div>

    
</article>