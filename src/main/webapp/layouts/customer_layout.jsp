<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
Object auth = session.getAttribute("auth");
Object userType = session.getAttribute("userType");

if (auth == null || !"cliente".equals(String.valueOf(userType))) {
    response.sendRedirect(request.getContextPath() + "/index.jsp?page=login");
    return;
}
%>
<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <%@ include file="../components/shared/head.jspf" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
</head>
<body>
    <div class="page-shell" style="min-height: 100vh; display: flex; flex-direction: column;">
        <header class="site-header">
            <div class="container">
                <%@ include file="../components/customer/customer_navbar.jspf" %>
            </div>
        </header>

        <main class="page-main" style="flex: 1 0 auto;">
            <div class="container section-padding-sm">
                <div class="split-layout split-layout--content-start" style="grid-template-columns: 280px minmax(0, 1fr); align-items: start;">
                    <aside>
                        <%@ include file="../components/customer/customer_sidebar.jspf" %>
                    </aside>

                    <section style="min-width: 0;">
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
    <script src="${pageContext.request.contextPath}/assets/js/customer.js"></script>
</body>
</html>