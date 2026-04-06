<%@ page import="java.util.List" %>
<%@ page import="Connection.Classes.Cliente" %>
<%@ page import="Connection.CRUD.ClienteCRUD" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>CRUD de Clientes</title>
</head>
<body>
    <h1>CRUD de Clientes</h1>

<%
    ClienteCRUD crud = new ClienteCRUD();

    // Capturar ação e id selecionado
    String action = request.getParameter("action");
    String idStr = request.getParameter("idCliente");

    // Variáveis para preencher o formulário
    String formId = "";
    String formNome = "";
    String formEmail = "";
    String formMorada = "";
    String formNIF = "";
    String formTele = "";
    String formData = "";

    if (action != null) {
        if ((action.equals("Apagar") || action.equals("AtualizarSelecionar")) && idStr != null && !idStr.isEmpty()) {
            int idCliente = Integer.parseInt(idStr);
            List<Cliente> clientes = crud.getAllCleintes();
            for (Cliente c : clientes) {
                if (c.getIdCliente() == idCliente) {
                    formId = String.valueOf(c.getIdCliente());
                    formNome = c.getNome();
                    formEmail = c.getEmail();
                    formMorada = c.getMorada();
                    formNIF = String.valueOf(c.getNIF());
                    formTele = String.valueOf(c.getTelemovel());
                    formData = (c.getDataNasc() != null) ? c.getDataNasc().toString() : "";
                    break;
                }
            }
        }

        if (idStr != null && !idStr.isEmpty()) {
            int idCliente = Integer.parseInt(idStr);
            int NIF = request.getParameter("NIF") != null && !request.getParameter("NIF").isEmpty() ? Integer.parseInt(request.getParameter("NIF")) : 0;
            int telemovel = request.getParameter("telemovel") != null && !request.getParameter("telemovel").isEmpty() ? Integer.parseInt(request.getParameter("telemovel")) : 0;
            LocalDate dataNasc = request.getParameter("data_nascimento") != null && !request.getParameter("data_nascimento").isEmpty() ? LocalDate.parse(request.getParameter("data_nascimento")) : null;
            String nome = request.getParameter("nome");
            String email = request.getParameter("email");
            String morada = request.getParameter("morada");

            Cliente cliente = new Cliente(idCliente, nome, email, morada, NIF, telemovel, dataNasc);

            switch(action) {
                case "Adicionar":
                    crud.Insert(cliente);
                    break;
                case "Atualizar":
                    crud.Update(cliente);
                    break;
                case "Apagar":
                    crud.Delete(cliente);
                    break;
            }
        }
    }
%>

    <h2>Adicionar / Atualizar Cliente</h2>
    <form method="post">
        <label>ID: </label><input type="text" name="idCliente" value="<%= formId %>" required><br>
        <label>Nome: </label><input type="text" name="nome" value="<%= formNome %>" required><br>
        <label>Email: </label><input type="email" name="email" value="<%= formEmail %>" required><br>
        <label>Morada: </label><input type="text" name="morada" value="<%= formMorada %>"><br>
        <label>NIF: </label><input type="number" name="NIF" value="<%= formNIF %>"><br>
        <label>Telemovel: </label><input type="number" name="telemovel" value="<%= formTele %>"><br>
        <label>Data Nascimento: </label><input type="date" name="data_nascimento" value="<%= formData %>"><br>
        <input type="submit" name="action" value="Adicionar">
        <input type="submit" name="action" value="Atualizar">
    </form>

    <h2>Lista de Clientes</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Nome</th>
            <th>Email</th>
            <th>Morada</th>
            <th>NIF</th>
            <th>Telemovel</th>
            <th>Data Nascimento</th>
            <th>Ações</th>
        </tr>
        <%
            List<Cliente> clientes = crud.getAllCleintes();
            for (Cliente c : clientes) {
        %>
        <tr>
            <td><%= c.getIdCliente() %></td>
            <td><%= c.getNome() %></td>
            <td><%= c.getEmail() %></td>
            <td><%= c.getMorada() %></td>
            <td><%= c.getNIF() %></td>
            <td><%= c.getTelemovel() %></td>
            <td><%= c.getDataNasc() %></td>
            <td>
                <!-- Botão para selecionar cliente e preencher formulário -->
                <form method="post" style="display:inline;">
                    <input type="hidden" name="idCliente" value="<%= c.getIdCliente() %>">
                    <input type="submit" name="action" value="Atualizar">
                </form>
                <!-- Botão para deletar -->
                <form method="post" style="display:inline;">
                    <input type="hidden" name="idCliente" value="<%= c.getIdCliente() %>">
                    <input type="submit" name="action" value="Apagar">
                </form>
            </td>
        </tr>
        <% } %>
    </table>
</body>
</html>