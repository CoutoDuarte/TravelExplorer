<%@ page import="java.util.List" %>
<%@ page import="Connection.Classes.Alojamento" %>
<%@ page import="Connection.CRUD.AlojamentoCRUD" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    AlojamentoCRUD alojamentoCRUD = new AlojamentoCRUD();

    String action = request.getParameter("action");

    if (action != null) {
        try {
            int idAlojamento = Integer.parseInt(request.getParameter("idAlojamento"));
            String nome = request.getParameter("nome");
            String morada = request.getParameter("morada");
            int numPessoas = Integer.parseInt(request.getParameter("num_pessoas"));
            String tipoQuarto = request.getParameter("tipo_quarto");
            String tipoEstadia = request.getParameter("tipo_estadia");
            float preco = Float.parseFloat(request.getParameter("preco"));

            Alojamento alojamento = new Alojamento(idAlojamento, nome, morada, numPessoas, tipoQuarto, tipoEstadia, preco);

            if ("Adicionar".equals(action)) {
                alojamentoCRUD.Insert(alojamento);
            } else if ("Atualizar".equals(action)) {
                alojamentoCRUD.Update(alojamento);
            } else if ("Apagar".equals(action)) {
                alojamentoCRUD.Delete(alojamento);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    List<Alojamento> alojamentos = alojamentoCRUD.getAllAlojamento();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CRUD de Alojamentos</title>
</head>
<body>
    <h1>CRUD de Alojamentos</h1>

    <h2>Adicionar / Atualizar Alojamento</h2>
    <form method="post">
        <label>ID:</label><input type="text" name="idAlojamento" value="" required><br>
        <label>Nome:</label><input type="text" name="nome" value="" required><br>
        <label>Morada:</label><input type="text" name="morada" value="" required><br>
        <label>Número de Pessoas:</label><input type="number" name="num_pessoas" value="" required><br>
        <label>Tipo de Quarto:</label><input type="text" name="tipo_quarto" value="" required><br>
        <label>Tipo de Estadia:</label><input type="text" name="tipo_estadia" value="" required><br>
        <label>Preço:</label><input type="number" step="0.01" name="preco" value="" required><br>

        <input type="submit" name="action" value="Adicionar">
        <input type="submit" name="action" value="Atualizar">
    </form>

    <h2>Lista de Alojamentos</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Nome</th>
            <th>Morada</th>
            <th>Número de Pessoas</th>
            <th>Tipo de Quarto</th>
            <th>Tipo de Estadia</th>
            <th>Preço</th>
            <th>Ações</th>
        </tr>
        <% for (Alojamento alojamento : alojamentos) { %>
        <tr>
            <form method="post">
                <td><input type="text" name="idAlojamento" value="<%= alojamento.getIdAlojamento() %>" readonly></td>
                <td><input type="text" name="nome" value="<%= alojamento.getNome() %>" required></td>
                <td><input type="text" name="morada" value="<%= alojamento.getMorada() %>" required></td>
                <td><input type="number" name="num_pessoas" value="<%= alojamento.getNumPessoas() %>" required></td>
                <td><input type="text" name="tipo_quarto" value="<%= alojamento.getTipoQuarto() %>" required></td>
                <td><input type="text" name="tipo_estadia" value="<%= alojamento.getTipoEstadia() %>" required></td>
                <td><input type="number" step="0.01" name="preco" value="<%= alojamento.getPreco() %>" required></td>
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
