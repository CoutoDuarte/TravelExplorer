<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% String go = request.getParameter("gradientOnly");
   boolean gradientOnly = "true".equals(go);
   String gsRaw = request.getParameter("gradientSeed") != null ? request.getParameter("gradientSeed").trim() : "1";
   String gSeed = "1";
   if ("2".equals(gsRaw)) gSeed = "2";
   else if ("3".equals(gsRaw)) gSeed = "3";
   String img = request.getParameter("image");
   String imagemUrl = request.getParameter("imagemUrl");
   if (imagemUrl != null && !imagemUrl.trim().isEmpty()) {
       img = imagemUrl.trim();
   }
   boolean hasHttpImg = img != null && (img.startsWith("http://") || img.startsWith("https://"));
   boolean useGradientBlock = gradientOnly || !hasHttpImg;
   String idPacoteCard = request.getParameter("idPacote");
   String isSaved = request.getParameter("isSaved");
   String showSave = request.getParameter("showSave");
   boolean saved = "true".equals(isSaved);
   boolean canSave = "true".equals(showSave) && idPacoteCard != null && !idPacoteCard.trim().isEmpty();
   String ctx = request.getContextPath();
   String redirectPage = request.getParameter("redirectPage");
   if (redirectPage == null || redirectPage.isEmpty()) redirectPage = "home";
   String routeLine = request.getParameter("routeLine");
   String metaLine = request.getParameter("metaLine");
   String datesLine = request.getParameter("datesLine");
   String promoBadge = request.getParameter("promoBadge");
   String priceOriginal = request.getParameter("priceOriginal");
   boolean showRoute = routeLine != null && !routeLine.trim().isEmpty();
   boolean showMeta = metaLine != null && !metaLine.trim().isEmpty();
   boolean showDates = datesLine != null && !datesLine.trim().isEmpty();
   boolean showPromoBadge = promoBadge != null && !promoBadge.trim().isEmpty();
   boolean showPriceOriginal = priceOriginal != null && !priceOriginal.trim().isEmpty();
   String detailPage = "offer-details";
   if (idPacoteCard != null && !idPacoteCard.trim().isEmpty()) {
       detailPage = "offer-details&idPacote=" + idPacoteCard.trim();
   }
%>
<article class="card public-offer-card">
    <div class="card__media<% if (useGradientBlock) { %> card__media--gradient card__media--gradient-<%= gSeed %><% } %>">
        <% if (hasHttpImg && !gradientOnly) { %>
        <img
            src="<%= img %>"
            alt="<%= request.getParameter("alt") != null ? request.getParameter("alt") : "" %>"
            loading="lazy"
            decoding="async"
            referrerpolicy="no-referrer"
            onerror="this.remove(); this.parentElement.classList.add('card__media--gradient', 'card__media--gradient-<%= gSeed %>', 'card__media--gradient-fallback');">
        <% } %>
    </div>

    <div class="card__body">
        <div class="card__meta">
            <% if (request.getParameter("tag1") != null && !request.getParameter("tag1").trim().isEmpty()) { %>
            <span class="card__tag"><%= request.getParameter("tag1") %></span>
            <% } %>
            <% if (showPromoBadge) { %>
            <span class="card__tag card__tag--promo"><%= promoBadge %></span>
            <% } %>
            <% if (showMeta) { %>
            <span class="card__tag"><%= metaLine %></span>
            <% } %>
        </div>

        <h3 class="card__title"><%= request.getParameter("title") != null ? request.getParameter("title") : "" %></h3>

        <% if (showRoute) { %>
        <p class="offer-card__route"><%= routeLine %></p>
        <% } %>

        <% if (showDates) { %>
        <p class="offer-card__dates"><%= datesLine %></p>
        <% } %>

        <% if (request.getParameter("description") != null && !request.getParameter("description").trim().isEmpty()) { %>
        <p class="offer-card__description"><%= request.getParameter("description") %></p>
        <% } %>

        <div class="card__footer">
            <div class="card__price-block">
                <% if (showPriceOriginal) { %>
                <span class="card__price card__price--original"><%= priceOriginal %></span>
                <% } %>
                <span class="card__price<% if (showPriceOriginal) { %> card__price--promo<% } %>"><%= request.getParameter("price") != null ? request.getParameter("price") : "" %></span>
            </div>
            <div class="actions-row">
                <a class="btn btn-secondary" href="<%= ctx %>/index.jsp?page=<%= detailPage %>">Ver detalhes</a>
                <% if (canSave) { %>
                    <% if (saved) { %>
                    <span class="btn btn-ghost" style="pointer-events: none;">Guardada</span>
                    <% } else { %>
                    <form action="<%= ctx %>/ClienteOfertaGuardadaServlet" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="save">
                        <input type="hidden" name="idPacote" value="<%= idPacoteCard %>">
                        <input type="hidden" name="redirect" value="<%= redirectPage %>">
                        <button type="submit" class="btn btn-ghost">Guardar oferta</button>
                    </form>
                    <% } %>
                <% } else if ("guest".equals(showSave)) { %>
                    <a class="btn btn-ghost" href="<%= ctx %>/index.jsp?page=login&amp;redirect=<%= java.net.URLEncoder.encode(redirectPage, "UTF-8") %>">Entrar para guardar</a>
                <% } %>
            </div>
        </div>
    </div>
</article>
