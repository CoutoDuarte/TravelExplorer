
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Connection.Classes.Cliente" %>
<%@ page import="Connection.Classes.Reserva" %>
<%@ page import="Connection.Classes.Pagamento" %>
<%@ page import="Connection.Classes.Pacote" %>
<%@ page import="Connection.Classes.Viagens" %>
<%@ page import="Connection.CRUD.ClienteCRUD" %>
<%@ page import="Connection.CRUD.ReservaCRUD" %>
<%@ page import="Connection.CRUD.PagamentoCRUD" %>
<%@ page import="Connection.CRUD.PacoteCRUD" %>
<%@ page import="Connection.CRUD.ViagemCRUD" %>
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