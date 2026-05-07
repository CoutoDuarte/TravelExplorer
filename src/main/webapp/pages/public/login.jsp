<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet,Connection.DBConnection,org.mindrot.jbcrypt.BCrypt" %>
<%
String loginErrorMessage = null;
String loginEmailValue = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    loginEmailValue = email != null ? email.trim() : "";
    String passwordValue = password != null ? password : "";

    if (loginEmailValue.isEmpty() || passwordValue.isEmpty()) {
        loginErrorMessage = "Preenche o email e a palavra-passe.";
    } else {
        try (Connection conn = DBConnection.getConnection()) {
            String clienteQuery = "SELECT idCliente, nome, password_hash FROM CLIENTE WHERE email = ?";

            try (PreparedStatement stmt = conn.prepareStatement(clienteQuery)) {
                stmt.setString(1, loginEmailValue);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        String passwordHash = rs.getString("password_hash");

                        if (passwordHash != null && !passwordHash.trim().isEmpty() && BCrypt.checkpw(passwordValue, passwordHash)) {
                            session.setAttribute("auth", true);
                            session.setAttribute("userType", "cliente");
                            session.setAttribute("userId", rs.getInt("idCliente"));
                            session.setAttribute("userName", rs.getString("nome"));
%>
<script>
    window.location.replace("<%= request.getContextPath() %>/index.jsp?page=customer-dashboard");
</script>
<%
                            return;
                        }
                    }
                }
            }

            String funcionarioQuery = "SELECT idFuncionario, nome, password_hash FROM FUNCIONARIO WHERE email = ?";

            try (PreparedStatement stmt = conn.prepareStatement(funcionarioQuery)) {
                stmt.setString(1, loginEmailValue);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        String passwordHash = rs.getString("password_hash");

                        if (passwordHash != null && !passwordHash.trim().isEmpty() && BCrypt.checkpw(passwordValue, passwordHash)) {
                            session.setAttribute("auth", true);
                            session.setAttribute("userType", "staff");
                            session.setAttribute("userId", rs.getInt("idFuncionario"));
                            session.setAttribute("userName", rs.getString("nome"));
%>
<script>
    window.location.replace("<%= request.getContextPath() %>/index.jsp?page=staff-dashboard");
</script>
<%
                            return;
                        }
                    }
                }
            }

            loginErrorMessage = "Email ou palavra-passe inválidos.";
        } catch (Exception e) {
            e.printStackTrace();
            loginErrorMessage = "Erro técnico: " + e.getClass().getName() + " - " + e.getMessage();
        }
    }
}
%>

<div class="public-page">
    <section class="public-page__section public-page__section--soft">
        <div class="container content-narrow">
            <div class="surface-block surface-block-xl">
                <div class="section-title">
                    <span class="section-title__eyebrow">Entrar</span>
                    <h1 class="section-title__heading">Acede à tua conta</h1>
                    <p class="section-title__description">
                        Inicia sessão para acompanhar reservas, guardar ofertas favoritas e aceder à tua área pessoal.
                    </p>
                </div>

                <form class="flow" action="${pageContext.request.contextPath}/index.jsp?page=login" method="post" style="margin-top: 2rem;">
                    <% if (loginErrorMessage != null) { %>
                    <p class="text-muted" style="color: #b42318;"><%= loginErrorMessage %></p>
                    <% } %>

                    <div>
                        <label for="loginEmail">Email</label>
                        <input type="email" id="loginEmail" name="email" placeholder="Ex.: filipe@email.com" required value="<%= loginEmailValue %>">
                    </div>

                    <div>
                        <label for="loginPassword">Palavra-passe</label>
                        <input type="password" id="loginPassword" name="password" placeholder="Introduz a tua palavra-passe" required>
                    </div>

                    <button class="btn btn-primary" type="submit" style="width: 100%; margin-top: 1rem;">
                        Entrar
                    </button>
                </form>

                <div class="surface-block" style="margin-top: 1.5rem;">
                    <div class="flow">
                        <h2 style="font-size: 1.15rem;">Ainda não tens conta?</h2>
                        <p class="text-muted">
                            Cria a tua conta para guardar ofertas favoritas e acompanhar futuras reservas.
                        </p>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=register">
                            Criar conta
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>