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
       if (img.startsWith("http://") || img.startsWith("https://")) {
           img = imagemUrl.trim();
       } else if (!img.startsWith("/")) {
           img = "/" + img;
       }
   }
   boolean hasImg = img != null && !img.trim().isEmpty();
   boolean useGradientBlock = gradientOnly || !hasImg;
   String idPacoteCard = request.getParameter("idPacote");
   String isSaved = request.getParameter("isSaved");
   String showSave = request.getParameter("showSave");
   boolean saved = "true".equals(isSaved);
   boolean canSave = "true".equals(showSave) && idPacoteCard != null && !idPacoteCard.trim().isEmpty();
   String ctx = request.getContextPath();
   String redirectPage = request.getParameter("redirectPage");
   if (redirectPage == null || redirectPage.isEmpty()) redirectPage = "destinations";
%>
<article class="card">
    <div class="card__media<% if (useGradientBlock) { %> card__media--gradient card__media--gradient-<%= gSeed %><% } %>">
        <% if (!useGradientBlock) { %>
        <img
            src="<%= (img.startsWith("http") ? img : ctx + img) %>"
            alt="<%= request.getParameter("alt") != null ? request.getParameter("alt") : "" %>"
            loading="lazy"
            decoding="async"
            referrerpolicy="no-referrer"
            onerror="this.classList.add('is-hidden'); this.parentElement.classList.add('card__media--gradient', 'card__media--gradient-<%= gSeed %>', 'card__media--gradient-fallback');">
        <% } %>
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
            <div class="actions-row">
                <% String detailPage = "offer-details";
                   if (idPacoteCard != null && !idPacoteCard.trim().isEmpty()) {
                       detailPage = "offer-details&idPacote=" + idPacoteCard.trim();
                   } %>
                <a class="btn btn-secondary" href="<%= ctx %>/index.jsp?page=<%= detailPage %>">Ver detalhe</a>
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
                    <a class="btn btn-ghost" href="<%= ctx %>/index.jsp?page=login">Guardar oferta</a>
                <% } %>
            </div>
        </div>
    </div>
</article>
