<%@ page import="java.util.List" %>
<%@ page import="Connection.Classes.Permissao" %>
<%@ page import="Connection.CRUD.PermissaoCRUD" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    PermissaoCRUD permissaoCRUD = new PermissaoCRUD();

    String action = request.getParameter("action");

    if (action != null) {
        try {
            int idPermissao = Integer.parseInt(request.getParameter("idPermissao"));
            String nome = request.getParameter("nome");
            String descricao = request.getParameter("descricao");

            Permissao permissao = new Permissao(idPermissao, nome, descricao);

            if ("Adicionar".equals(action)) {
                permissaoCRUD.insert(permissao);
            } else if ("Atualizar".equals(action)) {
                permissaoCRUD.update(permissao);
            } else if ("Apagar".equals(action)) {
                permissaoCRUD.delete(idPermissao);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    List<Permissao> permissoes = permissaoCRUD.getAll();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CRUD de Permissões</title>
</head>
<body>
    <h1>CRUD de Permissões</h1>

    <h2>Adicionar / Atualizar Permissão</h2>
    <form method="post">
        <label>ID:</label><input type="text" name="idPermissao" value="" required><br>
        <label>Nome:</label><input type="text" name="nome" value="" required><br>
        <label>Descrição:</label><input type="text" name="descricao" value="" required><br>

        <input type="submit" name="action" value="Adicionar">
        <input type="submit" name="action" value="Atualizar">
    </form>

    <h2>Lista de Permissões</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Nome</th>
            <th>Descrição</th>
            <th>Ações</th>
        </tr>
        <% for (Permissao permissao : permissoes) { %>
        <tr>
            <form method="post">
                <td><input type="text" name="idPermissao" value="<%= permissao.getIdPermissao() %>" readonly></td>
                <td><input type="text" name="nome" value="<%= permissao.getNome() %>" required></td>
                <td><input type="text" name="descricao" value="<%= permissao.getDescricao() %>" required></td>
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