<%-- Duarte: aqui poderá ser feita lógica futura para adaptar a navbar consoante o estado de autenticação. --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <%@ include file="../components/shared/head.jspf" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/public.css">
</head>
<body>
    <div class="page-shell">
        <header class="site-header">
            <div class="container">
                <%@ include file="../components/public/public_navbar.jspf" %>
            </div>
        </header>

        <main class="page-main">
            <jsp:include page="${contentPage}" />
        </main>

        <footer class="site-footer">
            <div class="container">
                <%@ include file="../components/shared/footer.jspf" %>
            </div>
        </footer>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/public.js"></script>
</body>
</html>