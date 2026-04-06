<%@ page import="java.util.List" %>
<%@ page import="Connection.Classes.Funcionario" %>
<%@ page import="Connection.CRUD.FuncionarioCRUD" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    FuncionarioCRUD funcionarioCRUD = new FuncionarioCRUD();

    String action = request.getParameter("action");

    if (action != null) {
        try {
            int idFuncionario = Integer.parseInt(request.getParameter("idFuncionario"));
            String nome = request.getParameter("nome");
            String email = request.getParameter("email");
            int telemovel = Integer.parseInt(request.getParameter("telemovel"));
            float salario = Float.parseFloat(request.getParameter("salario"));

            Funcionario funcionario = new Funcionario(idFuncionario, nome, email, telemovel, salario);

            if ("Adicionar".equals(action)) {
                funcionarioCRUD.Insert(funcionario);
            } else if ("Atualizar".equals(action)) {
                funcionarioCRUD.Update(funcionario);
            } else if ("Apagar".equals(action)) {
                funcionarioCRUD.Delete(funcionario);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    List<Funcionario> funcionarios = funcionarioCRUD.getAllFuncionarios();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CRUD de Funcionários</title>
</head>
<body>
    <h1>CRUD de Funcionários</h1>

    <h2>Adicionar / Atualizar Funcionário</h2>
    <form method="post">
        <label>ID:</label><input type="text" name="idFuncionario" value="" required><br>
        <label>Nome:</label><input type="text" name="nome" value="" required><br>
        <label>Email:</label><input type="email" name="email" value="" required><br>
        <label>Telemóvel:</label><input type="number" name="telemovel" value="" required><br>
        <label>Salário:</label><input type="number" step="0.01" name="salario" value="" required><br>

        <input type="submit" name="action" value="Adicionar">
        <input type="submit" name="action" value="Atualizar">
    </form>

    <h2>Lista de Funcionários</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Nome</th>
            <th>Email</th>
            <th>Telemóvel</th>
            <th>Salário</th>
            <th>Ações</th>
        </tr>
        <% for (Funcionario funcionario : funcionarios) { %>
        <tr>
            <form method="post">
                <td><input type="text" name="idFuncionario" value="<%= funcionario.getIdFuncionario() %>" readonly></td>
                <td><input type="text" name="nome" value="<%= funcionario.getNome() %>" required></td>
                <td><input type="email" name="email" value="<%= funcionario.getEmail() %>" required></td>
                <td><input type="number" name="telemovel" value="<%= funcionario.getTelemovel() %>" required></td>
                <td><input type="number" step="0.01" name="salario" value="<%= funcionario.getSalario() %>" required></td>
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
