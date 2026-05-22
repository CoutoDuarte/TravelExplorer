<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="Connection.Classes.Cliente" %>
<%@ page import="Connection.CRUD.ClienteCRUD" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%!
private String escapeHtml(String value) {
    if (value == null) {
        return "";
    }
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
}

private String safeValue(String value) {
    return value != null ? value : "";
}
%>
<%
Object userIdObj = session.getAttribute("userId");
Integer idCliente = null;
if (userIdObj != null) {
    try {
        idCliente = Integer.valueOf(userIdObj.toString());
    } catch (NumberFormatException ignored) {
        idCliente = null;
    }
}
if (idCliente == null) {
%>
<script>
    window.location.replace("<%= request.getContextPath() %>/index.jsp?page=login");
</script>
<%
    return;
}

String profileMessage = null;
String profileErrorMessage = null;
String profileNameValue = "";
String profileEmailValue = "";
String profilePhoneValue = "";
String profileAddressValue = "";
String profileNifValue = "";
String profileBirthDateValue = "";
ClienteCRUD clienteCRUD = new ClienteCRUD();

if ("POST".equalsIgnoreCase(request.getMethod())) {
    profileNameValue = request.getParameter("name") != null ? request.getParameter("name").trim() : "";
    profileEmailValue = request.getParameter("email") != null ? request.getParameter("email").trim() : "";
    profilePhoneValue = request.getParameter("phone") != null ? request.getParameter("phone").trim() : "";
    profileAddressValue = request.getParameter("address") != null ? request.getParameter("address").trim() : "";
    profileNifValue = request.getParameter("nif") != null ? request.getParameter("nif").trim() : "";
    profileBirthDateValue = request.getParameter("birthDate") != null ? request.getParameter("birthDate").trim() : "";
    String passwordValue = request.getParameter("password") != null ? request.getParameter("password") : "";
    String confirmPasswordValue = request.getParameter("confirmPassword") != null ? request.getParameter("confirmPassword") : "";
    boolean updatePassword = !passwordValue.isEmpty() || !confirmPasswordValue.isEmpty();

    if (profileNameValue.isEmpty()) {
        profileErrorMessage = "O nome completo é obrigatório.";
    } else if (profileEmailValue.isEmpty()) {
        profileErrorMessage = "O email é obrigatório.";
    } else if (!profilePhoneValue.isEmpty() && !profilePhoneValue.matches("\\d+")) {
        profileErrorMessage = "O telefone deve conter apenas números.";
    } else if (!profileNifValue.isEmpty() && !profileNifValue.matches("\\d+")) {
        profileErrorMessage = "O NIF deve conter apenas números.";
    } else if (updatePassword && !passwordValue.equals(confirmPasswordValue)) {
        profileErrorMessage = "As palavras-passe não coincidem.";
    } else {
        try {
            Cliente existingClient = clienteCRUD.findByEmail(profileEmailValue);
            if (existingClient != null && existingClient.getIdCliente() != idCliente) {
                profileErrorMessage = "Este email já está associado a outra conta.";
            } else {
                int phoneValue = profilePhoneValue.isEmpty() ? 0 : Integer.parseInt(profilePhoneValue);
                int nifValue = profileNifValue.isEmpty() ? 0 : Integer.parseInt(profileNifValue);
                LocalDate birthDateValue = profileBirthDateValue.isEmpty() ? null : LocalDate.parse(profileBirthDateValue);
                Cliente cliente = new Cliente(idCliente, profileNameValue, profileEmailValue, profileAddressValue, nifValue, phoneValue, birthDateValue);
                if (updatePassword) {
                    cliente.setPasswordHash(BCrypt.hashpw(passwordValue, BCrypt.gensalt()));
                }
                if (clienteCRUD.update(cliente)) {
                    session.setAttribute("userName", profileNameValue);
                    profileMessage = "Dados atualizados com sucesso.";
                } else {
                    profileErrorMessage = "Erro técnico: Não foi possível atualizar os dados.";
                }
            }
        } catch (Exception e) {
            profileErrorMessage = "Erro técnico: " + e.getMessage();
        }
    }
}

if (!"POST".equalsIgnoreCase(request.getMethod()) || profileMessage != null) {
    try {
        Cliente cliente = clienteCRUD.findById(idCliente);
        if (cliente != null) {
            profileNameValue = safeValue(cliente.getNome());
            profileEmailValue = safeValue(cliente.getEmail());
            profilePhoneValue = cliente.getTelemovel() > 0 ? String.valueOf(cliente.getTelemovel()) : "";
            profileAddressValue = safeValue(cliente.getMorada());
            profileNifValue = cliente.getNIF() > 0 ? String.valueOf(cliente.getNIF()) : "";
            profileBirthDateValue = cliente.getDataNasc() != null ? cliente.getDataNasc().toString() : "";
        }
    } catch (Exception e) {
        profileErrorMessage = "Erro técnico: " + e.getMessage();
    }
}
%>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Perfil" />
        <jsp:param name="heading" value="A minha conta" />
        <jsp:param name="description" value="Consulta e atualiza os teus dados pessoais e preferências da tua conta." />
    </jsp:include>

    <div class="surface-block surface-block-lg customer-action-panel">
        <form class="flow" action="${pageContext.request.contextPath}/index.jsp?page=profile" method="post">
            <% if (profileErrorMessage != null) { %>
                <p class="text-muted" style="color: #b42318;"><%= escapeHtml(profileErrorMessage) %></p>
            <% } %>
            <% if (profileMessage != null) { %>
                <p class="text-muted" style="color: #027a48;"><%= escapeHtml(profileMessage) %></p>
            <% } %>
            <div class="customer-dashboard-grid">
                <div>
                    <label for="profileName">Nome completo</label>
                    <input type="text" id="profileName" name="name" value="<%= escapeHtml(profileNameValue) %>" required>
                </div>

                <div>
                    <label for="profileEmail">Email</label>
                    <input type="email" id="profileEmail" name="email" value="<%= escapeHtml(profileEmailValue) %>" required>
                </div>

                <div>
                    <label for="profilePhone">Telefone</label>
                    <input type="tel" id="profilePhone" name="phone" value="<%= escapeHtml(profilePhoneValue) %>">
                </div>
            </div>

            <div class="customer-dashboard-grid">
                <div>
                    <label for="profileAddress">Morada</label>
                    <input type="text" id="profileAddress" name="address" value="<%= escapeHtml(profileAddressValue) %>">
                </div>

                <div>
                    <label for="profileNif">NIF</label>
                    <input type="text" id="profileNif" name="nif" value="<%= escapeHtml(profileNifValue) %>">
                </div>

                <div>
                    <label for="profileBirthDate">Data de nascimento</label>
                    <input type="date" id="profileBirthDate" name="birthDate" value="<%= escapeHtml(profileBirthDateValue) %>">
                </div>
            </div>

            <div class="customer-dashboard-grid">
                <div>
                    <label for="profilePassword">Nova palavra-passe</label>
                    <input type="password" id="profilePassword" name="password" placeholder="Introduz uma nova palavra-passe">
                </div>

                <div>
                    <label for="profileConfirmPassword">Confirmar palavra-passe</label>
                    <input type="password" id="profileConfirmPassword" name="confirmPassword" placeholder="Repete a nova palavra-passe">
                </div>
            </div>

            <div class="actions-row">
                <button class="btn btn-primary" type="submit">Guardar alterações</button>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp#hero-studio">Planear viagem</a>
            </div>

            
        </form>
    </div>
</div>
