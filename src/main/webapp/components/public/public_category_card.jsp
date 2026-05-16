<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String gsRaw = request.getParameter("gradientSeed") != null ? request.getParameter("gradientSeed").trim() : "1";
String gSeed = "1";
if ("2".equals(gsRaw)) {
    gSeed = "2";
} else if ("3".equals(gsRaw)) {
    gSeed = "3";
} else if ("4".equals(gsRaw)) {
    gSeed = "4";
} else if ("5".equals(gsRaw)) {
    gSeed = "5";
} else if ("6".equals(gsRaw)) {
    gSeed = "6";
}
%>
<article class="destination-card__overlay destination-card__overlay--<%= gSeed %>">
    <div class="destination-card__content">
        <h3 class="destination-card__title"><%= request.getParameter("title") != null ? request.getParameter("title") : "" %></h3>
        <p class="destination-card__text"><%= request.getParameter("text") != null ? request.getParameter("text") : "" %></p>
    </div>
</article>
