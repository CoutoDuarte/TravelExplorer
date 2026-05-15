<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<article class="destination-card__overlay">
    <div class="destination-card__content">
        <h3 class="destination-card__title"><%= request.getParameter("title") != null ? request.getParameter("title") : "" %></h3>
        <p class="destination-card__text"><%= request.getParameter("text") != null ? request.getParameter("text") : "" %></p>
    </div>

    
</article>