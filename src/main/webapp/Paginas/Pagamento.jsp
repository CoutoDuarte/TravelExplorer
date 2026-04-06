<%@ page import="java.util.List" %>
<%@ page import="Connection.Classes.Pagamento" %>
<%@ page import="Connection.CRUD.PagamentoCRUD" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    PagamentoCRUD pagamentoCRUD = new PagamentoCRUD();

    String action = request.getParameter("action");

    if (action != null) {
        try {
            int idPagamento = Integer.parseInt(request.getParameter("idPagamento"));
            float valor = Float.parseFloat(request.getParameter("valor"));
            String metodo = request.getParameter("metodo");
            java.sql.Date dataPagamento = java.sql.Date.valueOf(request.getParameter("data_pagamento"));
            int idCliente = Integer.parseInt(request.getParameter("idCliente"));
            int idReserva = Integer.parseInt(request.getParameter("idReserva"));

            Pagamento pagamento = new Pagamento(idPagamento, valor, metodo, dataPagamento, idCliente, idReserva);

            if ("Adicionar".equals(action)) {
                pagamentoCRUD.insert(pagamento);
            } else if ("Atualizar".equals(action)) {
                pagamentoCRUD.update(pagamento);
            } else if ("Apagar".equals(action)) {
                pagamentoCRUD.delete(idPagamento);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    List<Pagamento> pagamentos = pagamentoCRUD.getAll();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CRUD de Pagamentos</title>
</head>
<body>
    <h1>CRUD de Pagamentos</h1>

    <h2>Adicionar / Atualizar Pagamento</h2>
    <form method="post">
        <label>ID:</label><input type="text" name="idPagamento" value="" required><br>
        <label>Valor:</label><input type="number" step="0.01" name="valor" value="" required><br>
        <label>Método:</label><input type="text" name="metodo" value="" required><br>
        <label>Data de Pagamento:</label><input type="date" name="data_pagamento" value="" required><br>
        <label>ID Cliente:</label><input type="number" name="idCliente" value="" required><br>
        <label>ID Reserva:</label><input type="number" name="idReserva" value="" required><br>

        <input type="submit" name="action" value="Adicionar">
        <input type="submit" name="action" value="Atualizar">
    </form>

    <h2>Lista de Pagamentos</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Valor</th>
            <th>Método</th>
            <th>Data de Pagamento</th>
            <th>ID Cliente</th>
            <th>ID Reserva</th>
            <th>Ações</th>
        </tr>
        <% for (Pagamento pagamento : pagamentos) { %>
        <tr>
            <form method="post">
                <td><input type="text" name="idPagamento" value="<%= pagamento.getIdPagamento() %>" readonly></td>
                <td><input type="number" step="0.01" name="valor" value="<%= pagamento.getValor() %>" required></td>
                <td><input type="text" name="metodo" value="<%= pagamento.getMetodo() %>" required></td>
                <td><input type="date" name="data_pagamento" value="<%= pagamento.getDataPagamento().toString() %>" required></td>
                <td><input type="number" name="idCliente" value="<%= pagamento.getIdCliente() %>" required></td>
                <td><input type="number" name="idReserva" value="<%= pagamento.getIdReserva() %>" required></td>
                <td>
                    <input type="submit" name="action" value="Atualizar">
                    <input type="submit" name="action" value="Apagar">
                </td>
            </form>
        </tr>
        <% } %>
    </table>
</body>
</html>