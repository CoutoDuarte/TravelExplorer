<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<article class="destination-card__overlay" style="background:
    linear-gradient(180deg, rgba(34, 56, 67, 0.08) 15%, rgba(34, 56, 67, 0.7) 100%),
    url('${pageContext.request.contextPath}<%= request.getParameter("image") != null ? request.getParameter("image") : "" %>') center / cover no-repeat;">
    <div class="destination-card__content">
        <h3 class="destination-card__title"><%= request.getParameter("title") != null ? request.getParameter("title") : "" %></h3>
        <p class="destination-card__text"><%= request.getParameter("text") != null ? request.getParameter("text") : "" %></p>
    </div>

    <%-- Duarte: mais tarde este componente poderá receber um destino real e respetivo link dinâmico. --%>
</article>