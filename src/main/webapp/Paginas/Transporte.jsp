<%@ page import="java.util.List" %>
<%@ page import="Connection.Classes.Transporte" %>
<%@ page import="Connection.CRUD.TransporteCRUD" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    TransporteCRUD transporteCRUD = new TransporteCRUD();

    String action = request.getParameter("action");

    if (action != null) {
        try {
            int idTransporte = Integer.parseInt(request.getParameter("idTransporte"));
            String empresa = request.getParameter("empresa");
            String tipo = request.getParameter("tipo");
            String origem = request.getParameter("origem");
            String destino = request.getParameter("destino");
            java.sql.Timestamp dataHoraPartida = java.sql.Timestamp.valueOf(request.getParameter("data_hora_partida").replace("T", " ") + ":00");
            java.sql.Timestamp dataHoraChegada = java.sql.Timestamp.valueOf(request.getParameter("data_hora_chegada").replace("T", " ") + ":00");
            float preco = Float.parseFloat(request.getParameter("preco"));
            int lugares = Integer.parseInt(request.getParameter("lugares"));

            Transporte transporte = new Transporte(idTransporte, empresa, tipo, origem, destino, dataHoraPartida, dataHoraChegada, preco, lugares);

            if ("Adicionar".equals(action)) {
                transporteCRUD.insert(transporte);
            } else if ("Atualizar".equals(action)) {
                transporteCRUD.update(transporte);
            } else if ("Apagar".equals(action)) {
                transporteCRUD.delete(idTransporte);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    List<Transporte> transportes = transporteCRUD.getAll();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CRUD de Transportes</title>
</head>
<body>
    <h1>CRUD de Transportes</h1>

    <h2>Adicionar / Atualizar Transporte</h2>
    <form method="post">
        <label>ID:</label><input type="text" name="idTransporte" value="" required><br>
        <label>Empresa:</label><input type="text" name="empresa" value="" required><br>
        <label>Tipo:</label><input type="text" name="tipo" value="" required><br>
        <label>Origem:</label><input type="text" name="origem" value="" required><br>
        <label>Destino:</label><input type="text" name="destino" value="" required><br>
        <label>Data/Hora Partida:</label><input type="datetime-local" name="data_hora_partida" value="" required><br>
        <label>Data/Hora Chegada:</label><input type="datetime-local" name="data_hora_chegada" value="" required><br>
        <label>Preço:</label><input type="number" step="0.01" name="preco" value="" required><br>
        <label>Lugares:</label><input type="number" name="lugares" value="" required><br>

        <input type="submit" name="action" value="Adicionar">
        <input type="submit" name="action" value="Atualizar">
    </form>

    <h2>Lista de Transportes</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Empresa</th>
            <th>Tipo</th>
            <th>Origem</th>
            <th>Destino</th>
            <th>Data/Hora Partida</th>
            <th>Data/Hora Chegada</th>
            <th>Preço</th>
            <th>Lugares</th>
            <th>Ações</th>
        </tr>
        <% for (Transporte transporte : transportes) { 
            String partida = transporte.getDataHoraPartida().toLocalDateTime().toString();
            String chegada = transporte.getDataHoraChegada().toLocalDateTime().toString();
        %>
        <tr>
            <form method="post">
                <td><input type="text" name="idTransporte" value="<%= transporte.getIdTransporte() %>" readonly></td>
                <td><input type="text" name="empresa" value="<%= transporte.getEmpresa() %>" required></td>
                <td><input type="text" name="tipo" value="<%= transporte.getTipo() %>" required></td>
                <td><input type="text" name="origem" value="<%= transporte.getOrigem() %>" required></td>
                <td><input type="text" name="destino" value="<%= transporte.getDestino() %>" required></td>
                <td><input type="datetime-local" name="data_hora_partida" value="<%= partida %>" required></td>
                <td><input type="datetime-local" name="data_hora_chegada" value="<%= chegada %>" required></td>
                <td><input type="number" step="0.01" name="preco" value="<%= transporte.getPreco() %>" required></td>
                <td><input type="number" name="lugares" value="<%= transporte.getLugares() %>" required></td>
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