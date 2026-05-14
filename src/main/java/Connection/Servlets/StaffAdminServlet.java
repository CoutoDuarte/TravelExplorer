package Connection.Servlets;

import java.io.IOException;

import Connection.CRUD.FuncionarioCRUD;
import Connection.Classes.Funcionario;
import Connection.Security.StaffAuth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/staff-admin")
public class StaffAdminServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String ctx = req.getContextPath();
        if (!StaffAuth.isStaffLoggedIn(req)) {
            resp.sendRedirect(ctx + "/index.jsp?page=login");
            return;
        }
        if (!StaffAuth.hasPermission(req, "STAFF_CREATE_USERS")) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-dashboard&error=no-permission");
            return;
        }
        String nome = trim(req.getParameter("nome"));
        String email = trim(req.getParameter("email"));
        String telefoneStr = trim(req.getParameter("telefone"));
        String salarioStr = trim(req.getParameter("salario"));
        String password = req.getParameter("password");
        String idFuncaoStr = trim(req.getParameter("idFuncao"));
        if (nome.isEmpty() || email.isEmpty() || telefoneStr.isEmpty() || salarioStr.isEmpty()
                || password == null || password.isEmpty() || idFuncaoStr.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-admin&error=invalid-data&openCreate=1");
            return;
        }
        int telefone;
        float salario;
        int idFuncao;
        try {
            telefone = Integer.parseInt(telefoneStr);
            salario = Float.parseFloat(salarioStr.replace(',', '.'));
            idFuncao = Integer.parseInt(idFuncaoStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-admin&error=invalid-data&openCreate=1");
            return;
        }
        FuncionarioCRUD crud = new FuncionarioCRUD();
        if (crud.findByEmail(email) != null) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-admin&error=email-exists&openCreate=1");
            return;
        }
        Funcionario funcionario = new Funcionario(0, nome, email, telefone, salario);
        if (!crud.createStaffWithRole(funcionario, password, idFuncao)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-admin&error=invalid-data&openCreate=1");
            return;
        }
        resp.sendRedirect(ctx + "/index.jsp?page=staff-admin&success=staff-created");
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
