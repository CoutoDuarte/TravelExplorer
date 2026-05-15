<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% String stExtra = request.getParameter("extraClass"); %>
<div class="section-title<%= stExtra != null && !stExtra.trim().isEmpty() ? " " + stExtra.trim() : "" %>">
    <span class="section-title__eyebrow"><%= request.getParameter("eyebrow") != null ? request.getParameter("eyebrow") : "" %></span>
    <h2 class="section-title__heading"><%= request.getParameter("heading") != null ? request.getParameter("heading") : "" %></h2>
    <p class="section-title__description"><%= request.getParameter("description") != null ? request.getParameter("description") : "" %></p>

    
</div>