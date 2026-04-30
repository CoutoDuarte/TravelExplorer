<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<div class="section-title">
    <span class="section-title__eyebrow"><%= request.getParameter("eyebrow") != null ? request.getParameter("eyebrow") : "" %></span>
    <h2 class="section-title__heading"><%= request.getParameter("heading") != null ? request.getParameter("heading") : "" %></h2>
    <p class="section-title__description"><%= request.getParameter("description") != null ? request.getParameter("description") : "" %></p>

    
</div>