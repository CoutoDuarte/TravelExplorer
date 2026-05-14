package Connection.Servlets;

import java.io.IOException;
import java.time.LocalDate;

import Connection.CRUD.ComunicacaoCRUD;
import Connection.Classes.Comunicacao;
import Connection.Security.StaffAuth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/staff-communication")
public class StaffCommunicationServlet extends HttpServlet {

    private final ComunicacaoCRUD comunicacaoCRUD = new ComunicacaoCRUD();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/index.jsp?page=staff-communication");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String ctx = req.getContextPath();
        if (!StaffAuth.isStaffLoggedIn(req)) {
            resp.sendRedirect(ctx + "/index.jsp?page=login");
            return;
        }
        if (!StaffAuth.hasPermission(req, "STAFF_COMMUNICATION")) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-dashboard&error=no-permission");
            return;
        }
        String action = req.getParameter("action");
        if (action == null || action.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&error=invalid-data");
            return;
        }
        try {
            switch (action) {
                case "create-communication":
                    handleCreate(req, resp, ctx);
                    break;
                case "update-communication":
                    handleUpdate(req, resp, ctx);
                    break;
                case "delete-communication":
                    handleDelete(req, resp, ctx);
                    break;
                default:
                    resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&error=invalid-data");
            }
        } catch (Exception e) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&error=invalid-data");
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        String titulo = trim(req.getParameter("titulo"));
        String canal = trim(req.getParameter("canal"));
        String segmento = trim(req.getParameter("segmento"));
        String estado = trim(req.getParameter("estado"));
        String mensagem = req.getParameter("mensagem");
        if (mensagem == null) {
            mensagem = "";
        }
        LocalDate data = parseDate(req.getParameter("data_comunicacao"));
        int idCliente = parseIntOrZero(req.getParameter("idCliente"));
        if (titulo.isEmpty() || canal.isEmpty() || estado.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&error=invalid-data&openCreate=1");
            return;
        }
        Comunicacao c = new Comunicacao(0, titulo, canal, segmento != null ? segmento : "", data, estado, mensagem, idCliente);
        if (!comunicacaoCRUD.create(c)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&error=invalid-data&openCreate=1");
            return;
        }
        resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&success=communication-created");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int id = Integer.parseInt(req.getParameter("idComunicacao"));
        String titulo = trim(req.getParameter("titulo"));
        String canal = trim(req.getParameter("canal"));
        String segmento = trim(req.getParameter("segmento"));
        String estado = trim(req.getParameter("estado"));
        String mensagem = req.getParameter("mensagem");
        if (mensagem == null) {
            mensagem = "";
        }
        LocalDate data = parseDate(req.getParameter("data_comunicacao"));
        int idCliente = parseIntOrZero(req.getParameter("idCliente"));
        if (titulo.isEmpty() || canal.isEmpty() || estado.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&selectedComunicacao=" + id + "&error=invalid-data");
            return;
        }
        if (comunicacaoCRUD.findById(id) == null) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&error=invalid-data");
            return;
        }
        Comunicacao c = new Comunicacao(id, titulo, canal, segmento != null ? segmento : "", data, estado, mensagem, idCliente);
        if (!comunicacaoCRUD.update(c)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&selectedComunicacao=" + id + "&error=invalid-data");
            return;
        }
        resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&success=communication-updated");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int id = Integer.parseInt(req.getParameter("idComunicacao"));
        comunicacaoCRUD.deleteById(id);
        resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&success=communication-deleted");
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private static LocalDate parseDate(String s) {
        String t = trim(s);
        if (t.isEmpty()) {
            return null;
        }
        return LocalDate.parse(t);
    }

    private static int parseIntOrZero(String s) {
        String t = trim(s);
        if (t.isEmpty()) {
            return 0;
        }
        return Integer.parseInt(t);
    }
}
