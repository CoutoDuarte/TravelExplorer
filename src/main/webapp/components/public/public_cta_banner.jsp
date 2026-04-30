<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<div class="public-callout">
    <div class="public-callout__content">
        <h2 class="public-callout__title"><%= request.getParameter("title") != null ? request.getParameter("title") : "" %></h2>
        <p class="public-callout__text"><%= request.getParameter("text") != null ? request.getParameter("text") : "" %></p>
    </div>

    <a class="btn btn-primary" href="${pageContext.request.contextPath}<%= request.getParameter("href") != null ? request.getParameter("href") : "" %>">
        <%= request.getParameter("buttonText") != null ? request.getParameter("buttonText") : "" %>
    </a>

    
</div>