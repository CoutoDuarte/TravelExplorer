<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.Types,Connection.DBConnection,org.mindrot.jbcrypt.BCrypt" %>
<%
String registerErrorMessage = null;
String registerNameValue = "";
String registerEmailValue = "";
String registerPhoneValue = "";
boolean registerTermsChecked = false;

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");
    String phone = request.getParameter("phone");
    String terms = request.getParameter("terms");

    registerNameValue = name != null ? name.trim() : "";
    registerEmailValue = email != null ? email.trim() : "";
    registerPhoneValue = phone != null ? phone.trim() : "";
    String passwordValue = password != null ? password : "";
    String confirmPasswordValue = confirmPassword != null ? confirmPassword : "";
    registerTermsChecked = terms != null;

    if (registerNameValue.isEmpty() || registerEmailValue.isEmpty() || passwordValue.isEmpty() || confirmPasswordValue.isEmpty()) {
        registerErrorMessage = "Preenche os campos obrigatórios.";
    } else if (!passwordValue.equals(confirmPasswordValue)) {
        registerErrorMessage = "As palavras-passe não coincidem.";
    } else if (!registerTermsChecked) {
        registerErrorMessage = "Tens de aceitar os termos e condições.";
    } else if (!registerPhoneValue.isEmpty() && !registerPhoneValue.matches("\\d+")) {
        registerErrorMessage = "O telefone deve conter apenas números.";
    } else {
        try (Connection conn = DBConnection.getConnection()) {
            boolean emailExists = false;

            String emailClienteQuery = "SELECT 1 FROM CLIENTE WHERE email = ?";
            try (PreparedStatement stmt = conn.prepareStatement(emailClienteQuery)) {
                stmt.setString(1, registerEmailValue);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        emailExists = true;
                    }
                }
            }

            if (!emailExists) {
                String emailFuncionarioQuery = "SELECT 1 FROM FUNCIONARIO WHERE email = ?";
                try (PreparedStatement stmt = conn.prepareStatement(emailFuncionarioQuery)) {
                    stmt.setString(1, registerEmailValue);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            emailExists = true;
                        }
                    }
                }
            }

            if (emailExists) {
                registerErrorMessage = "Este email já está registado.";
            } else {
                int nextIdCliente = 1;

                String nextIdQuery = "SELECT COALESCE(MAX(idCliente), 0) + 1 FROM CLIENTE";
                try (PreparedStatement stmt = conn.prepareStatement(nextIdQuery);
                     ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        nextIdCliente = rs.getInt(1);
                    }
                }

                String passwordHash = BCrypt.hashpw(passwordValue, BCrypt.gensalt());
                String insertQuery = "INSERT INTO CLIENTE (idCliente, nome, email, morada, NIF, telemovel, data_nascimento, password_hash) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

                try (PreparedStatement stmt = conn.prepareStatement(insertQuery)) {
                    stmt.setInt(1, nextIdCliente);
                    stmt.setString(2, registerNameValue);
                    stmt.setString(3, registerEmailValue);
                    stmt.setString(4, "");
                    stmt.setInt(5, 0);

                    if (registerPhoneValue.isEmpty()) {
                        stmt.setInt(6, 0);
                    } else {
                        stmt.setInt(6, Integer.parseInt(registerPhoneValue));
                    }

                    stmt.setNull(7, Types.DATE);
                    stmt.setString(8, passwordHash);
                    stmt.executeUpdate();
%>
<script>
    window.location.replace("<%= request.getContextPath() %>/index.jsp?page=login");
</script>
<%
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            registerErrorMessage = "Erro técnico: " + e.getClass().getName() + " - " + e.getMessage();
        }
    }
}
%>

<div class="public-page">
    <section class="public-page__section public-page__section--soft">
        <div class="container content-narrow">
            <div class="surface-block surface-block-xl">
                <div class="section-title">
                    <span class="section-title__eyebrow">Criar conta</span>
                    <h1 class="section-title__heading">Regista-te no TravelExplorer</h1>
                    <p class="section-title__description">
                        Cria a tua conta para guardar ofertas favoritas, acompanhar reservas e aceder à tua área pessoal.
                    </p>
                </div>

                <form class="flow" action="${pageContext.request.contextPath}/index.jsp?page=register" method="post" style="margin-top: 2rem;">
                    <% if (registerErrorMessage != null) { %>
                    <p class="text-muted" style="color: #b42318;"><%= registerErrorMessage %></p>
                    <% } %>

                    <div>
                        <label for="registerName">Nome completo</label>
                        <input type="text" id="registerName" name="name" placeholder="Ex.: Filipe Aroso" required value="<%= registerNameValue %>">
                    </div>

                    <div>
                        <label for="registerEmail">Email</label>
                        <input type="email" id="registerEmail" name="email" placeholder="Ex.: filipe@email.com" required value="<%= registerEmailValue %>">
                    </div>

                    <div>
                        <label for="registerPassword">Palavra-passe</label>
                        <input type="password" id="registerPassword" name="password" placeholder="Cria uma palavra-passe" required>
                    </div>

                    <div>
                        <label for="registerConfirmPassword">Confirmar palavra-passe</label>
                        <input type="password" id="registerConfirmPassword" name="confirmPassword" placeholder="Repete a palavra-passe" required>
                    </div>

                    <div>
                        <label for="registerPhone">Telefone</label>
                        <input type="tel" id="registerPhone" name="phone" placeholder="Ex.: 912345678" value="<%= registerPhoneValue %>">
                    </div>

                    <div style="display: flex; flex-direction: column; gap: 0.85rem; margin-top: 0.5rem;">
                        <label style="display: inline-flex; align-items: center; gap: 0.5rem; margin-bottom: 0; font-weight: 500;">
                            <input type="checkbox" name="terms" style="width: auto;" <%= registerTermsChecked ? "checked" : "" %>>
                            Aceito os termos e condições
                        </label>
                    </div>

                    <button class="btn btn-primary" type="submit" style="width: 100%; margin-top: 1rem;">
                        Criar conta
                    </button>
                </form>

                <div class="surface-block" style="margin-top: 1.5rem;">
                    <div class="flow">
                        <h2 style="font-size: 1.15rem;">Já tens conta?</h2>
                        <p class="text-muted">
                            Entra com a tua conta para continuar a explorar ofertas e acompanhar as tuas reservas.
                        </p>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=login">
                            Ir para o login
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>