<%@ page import="java.util.List" %>
<%@ page import="Connection.Classes.Viagens" %>
<%@ page import="Connection.CRUD.ViagemCRUD" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    ViagemCRUD viagemCRUD = new ViagemCRUD();

    String action = request.getParameter("action");

    if (action != null) {
        try {
            int idViagem = Integer.parseInt(request.getParameter("idViagem"));
            int numeroBilhetesAdulto = Integer.parseInt(request.getParameter("numero_bilhetes_adulto"));
            int numeroBilhetesCrianca = Integer.parseInt(request.getParameter("numero_bilhetes_crianca"));
            float preco = Float.parseFloat(request.getParameter("preco"));
            String origem = request.getParameter("origem");
            String destino = request.getParameter("destino");
            java.sql.Timestamp dataHoraPartida = java.sql.Timestamp.valueOf(request.getParameter("data_hora_partida").replace("T", " ") + ":00");
            java.sql.Timestamp dataHoraRegresso = java.sql.Timestamp.valueOf(request.getParameter("data_hora_regresso").replace("T", " ") + ":00");
            String descricao = request.getParameter("descricao");
            String empresa = request.getParameter("empresa");

            Viagens viagem = new Viagens(idViagem, numeroBilhetesAdulto, numeroBilhetesCrianca, preco, origem, destino, dataHoraPartida, dataHoraRegresso, descricao, empresa);

            if ("Adicionar".equals(action)) {
                viagemCRUD.insert(viagem);
            } else if ("Atualizar".equals(action)) {
                viagemCRUD.update(viagem);
            } else if ("Apagar".equals(action)) {
                viagemCRUD.delete(idViagem);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    List<Viagens> viagens = viagemCRUD.getAll();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CRUD de Viagens</title>
</head>
<body>
    <h1>CRUD de Viagens</h1>

    <h2>Adicionar / Atualizar Viagem</h2>
    <form method="post">
        <label>ID:</label><input type="text" name="idViagem" value="" required><br>
        <label>Número de Bilhetes Adulto:</label><input type="number" name="numero_bilhetes_adulto" value="" required><br>
        <label>Número de Bilhetes Criança:</label><input type="number" name="numero_bilhetes_crianca" value="" required><br>
        <label>Preço:</label><input type="number" step="0.01" name="preco" value="" required><br>
        <label>Origem:</label><input type="text" name="origem" value="" required><br>
        <label>Destino:</label><input type="text" name="destino" value="" required><br>
        <label>Data/Hora Partida:</label><input type="datetime-local" name="data_hora_partida" value="" required><br>
        <label>Data/Hora Regresso:</label><input type="datetime-local" name="data_hora_regresso" value="" required><br>
        <label>Descrição:</label><input type="text" name="descricao" value="" required><br>
        <label>Empresa:</label><input type="text" name="empresa" value="" required><br>

        <input type="submit" name="action" value="Adicionar">
        <input type="submit" name="action" value="Atualizar">
    </form>

    <h2>Lista de Viagens</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Bilhetes Adulto</th>
            <th>Bilhetes Criança</th>
            <th>Preço</th>
            <th>Origem</th>
            <th>Destino</th>
            <th>Data/Hora Partida</th>
            <th>Data/Hora Regresso</th>
            <th>Descrição</th>
            <th>Empresa</th>
            <th>Ações</th>
        </tr>
        <% for (Viagens viagem : viagens) {
            String partida = viagem.getDataHoraPartida().toLocalDateTime().toString();
            String regresso = viagem.getDataHoraRegresso().toLocalDateTime().toString();
        %>
        <tr>
            <form method="post">
                <td><input type="text" name="idViagem" value="<%= viagem.getIdViagem() %>" readonly></td>
                <td><input type="number" name="numero_bilhetes_adulto" value="<%= viagem.getNumBilhetesAdulto() %>" required></td>
                <td><input type="number" name="numero_bilhetes_crianca" value="<%= viagem.getNumBilhetesCrianca() %>" required></td>
                <td><input type="number" step="0.01" name="preco" value="<%= viagem.getPreco() %>" required></td>
                <td><input type="text" name="origem" value="<%= viagem.getOrigem() %>" required></td>
                <td><input type="text" name="destino" value="<%= viagem.getDestino() %>" required></td>
                <td><input type="datetime-local" name="data_hora_partida" value="<%= partida %>" required></td>
                <td><input type="datetime-local" name="data_hora_regresso" value="<%= regresso %>" required></td>
                <td><input type="text" name="descricao" value="<%= viagem.getDescricao() %>" required></td>
                <td><input type="text" name="empresa" value="<%= viagem.getEmpresa() %>" required></td>
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