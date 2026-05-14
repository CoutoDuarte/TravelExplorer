<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <%@ include file="../components/shared/head.jspf" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/staff.css">
</head>
<body>
    <div class="page-shell" style="min-height: 100vh; display: flex; flex-direction: column;">
        <header class="site-header">
            <div class="container">
                <%@ include file="../components/staff/navbar.jspf" %>
            </div>
        </header>

        <main class="page-main" style="flex: 1 0 auto;">
            <div class="container section-padding-sm">
                <div class="split-layout split-layout--content-start" style="grid-template-columns: 300px minmax(0, 1fr); align-items: start;">
                    <aside>
                        <%@ include file="../components/staff/sidebar.jspf" %>
                    </aside>

                    <section style="min-width: 0;">
                        <% if ("no-permission".equals(request.getParameter("error"))) { %>
                        <div class="surface-block surface-block-lg" style="margin-bottom: 1rem;">
                            <p class="text-muted" style="color: #b42318;">Não tens permissão para aceder a esta área.</p>
                        </div>
                        <% } %>
                        <jsp:include page="${contentPage}" />
                    </section>
                </div>
            </div>
        </main>

        <footer class="site-footer" style="margin-top: 2rem; flex-shrink: 0;">
            <div class="container">
                <%@ include file="../components/shared/footer.jspf" %>
            </div>
        </footer>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/staff.js"></script>
</body>
</html>