<%@ page import="java.util.List" %>
<%@ page import="Connection.Classes.Pacote" %>
<%@ page import="Connection.CRUD.PacoteCRUD" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    PacoteCRUD pacoteCRUD = new PacoteCRUD();

    String action = request.getParameter("action");

    if (action != null) {
        try {
            int idPacote = Integer.parseInt(request.getParameter("idPacote"));
            String descricao = request.getParameter("descricao");
            String nome = request.getParameter("nome");
            float precoBase = Float.parseFloat(request.getParameter("preco_base"));
            int numAdultos = Integer.parseInt(request.getParameter("numero_pessoas_adultas"));
            int numCriancas = Integer.parseInt(request.getParameter("numero_criancas"));
            int idReserva = Integer.parseInt(request.getParameter("idReserva"));

            Pacote pacote = new Pacote(idPacote, descricao, nome, precoBase, numAdultos, numCriancas, idReserva);

            if ("Adicionar".equals(action)) {
                pacoteCRUD.Insert(pacote);
            } else if ("Atualizar".equals(action)) {
                pacoteCRUD.Update(pacote);
            } else if ("Apagar".equals(action)) {
                pacoteCRUD.Delete(pacote);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    List<Pacote> pacotes = pacoteCRUD.getAllPacotes();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CRUD de Pacotes</title>
</head>
<body>
    <h1>CRUD de Pacotes</h1>

    <h2>Adicionar / Atualizar Pacote</h2>
    <form method="post">
        <label>ID:</label><input type="text" name="idPacote" value="" required><br>
        <label>Descrição:</label><input type="text" name="descricao" value="" required><br>
        <label>Nome:</label><input type="text" name="nome" value="" required><br>
        <label>Preço Base:</label><input type="number" step="0.01" name="preco_base" value="" required><br>
        <label>Número de Adultos:</label><input type="number" name="numero_pessoas_adultas" value="" required><br>
        <label>Número de Crianças:</label><input type="number" name="numero_criancas" value="" required><br>
        <label>ID Reserva:</label><input type="number" name="idReserva" value="" required><br>

        <input type="submit" name="action" value="Adicionar">
        <input type="submit" name="action" value="Atualizar">
    </form>

    <h2>Lista de Pacotes</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Descrição</th>
            <th>Nome</th>
            <th>Preço Base</th>
            <th>Número de Adultos</th>
            <th>Número de Crianças</th>
            <th>ID Reserva</th>
            <th>Ações</th>
        </tr>
        <% for (Pacote pacote : pacotes) { %>
        <tr>
            <form method="post">
                <td><input type="text" name="idPacote" value="<%= pacote.getIdPacote() %>" readonly></td>
                <td><input type="text" name="descricao" value="<%= pacote.getDescricao() %>" required></td>
                <td><input type="text" name="nome" value="<%= pacote.getNome() %>" required></td>
                <td><input type="number" step="0.01" name="preco_base" value="<%= pacote.getPrecoBase() %>" required></td>
                <td><input type="number" name="numero_pessoas_adultas" value="<%= pacote.getNumAdultos() %>" required></td>
                <td><input type="number" name="numero_criancas" value="<%= pacote.getNumCriancas() %>" required></td>
                <td><input type="number" name="idReserva" value="<%= pacote.getIdReserva() %>" required></td>
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