<%@ page import="java.util.List" %>
<%@ page import="Connection.Classes.Reserva" %>
<%@ page import="Connection.CRUD.ReservaCRUD" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    ReservaCRUD reservaCRUD = new ReservaCRUD();

    String action = request.getParameter("action");

    if (action != null) {
        try {
            int idReserva = Integer.parseInt(request.getParameter("idReserva"));
            java.time.LocalDate dataReserva = java.time.LocalDate.parse(request.getParameter("data_reserva"));
            float totalPagar = Float.parseFloat(request.getParameter("total_pagar"));
            String estado = request.getParameter("estado");
            int idCliente = Integer.parseInt(request.getParameter("idCliente"));
            int idPacote = Integer.parseInt(request.getParameter("idPacote"));

            Reserva reserva = new Reserva(idReserva, dataReserva, totalPagar, estado, idCliente, idPacote);

            if ("Adicionar".equals(action)) {
                reservaCRUD.Insert(reserva);
            } else if ("Atualizar".equals(action)) {
                reservaCRUD.Update(reserva);
            } else if ("Apagar".equals(action)) {
                reservaCRUD.Delete(reserva);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    List<Reserva> reservas = reservaCRUD.getAllReservas();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CRUD de Reservas</title>
</head>
<body>
    <h1>CRUD de Reservas</h1>

    <h2>Adicionar / Atualizar Reserva</h2>
    <form method="post">
        <label>ID:</label><input type="text" name="idReserva" value="" required><br>
        <label>Data da Reserva:</label><input type="date" name="data_reserva" value="" required><br>
        <label>Total a Pagar:</label><input type="number" step="0.01" name="total_pagar" value="" required><br>
        <label>Estado:</label><input type="text" name="estado" value="" required><br>
        <label>ID Cliente:</label><input type="number" name="idCliente" value="" required><br>
        <label>ID Pacote:</label><input type="number" name="idPacote" value="" required><br>

        <input type="submit" name="action" value="Adicionar">
        <input type="submit" name="action" value="Atualizar">
    </form>

    <h2>Lista de Reservas</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Data da Reserva</th>
            <th>Total a Pagar</th>
            <th>Estado</th>
            <th>ID Cliente</th>
            <th>ID Pacote</th>
            <th>Ações</th>
        </tr>
        <% for (Reserva reserva : reservas) { %>
        <tr>
            <form method="post">
                <td><input type="text" name="idReserva" value="<%= reserva.getIdReserva() %>" readonly></td>
                <td><input type="date" name="data_reserva" value="<%= reserva.getDataReserva().toString() %>" required></td>
                <td><input type="number" step="0.01" name="total_pagar" value="<%= reserva.getTotalPagar() %>" required></td>
                <td><input type="text" name="estado" value="<%= reserva.getEstado() %>" required></td>
                <td><input type="number" name="idCliente" value="<%= reserva.getIdCliente() %>" required></td>
                <td><input type="number" name="idPacote" value="<%= reserva.getIdPacote() %>" required></td>
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
