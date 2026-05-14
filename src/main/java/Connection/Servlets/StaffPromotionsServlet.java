package Connection.Servlets;

import java.io.IOException;
import java.time.LocalDate;

import Connection.CRUD.PromocaoCRUD;
import Connection.Classes.Promocao;
import Connection.Security.StaffAuth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/staff-promotions")
public class StaffPromotionsServlet extends HttpServlet {

    private final PromocaoCRUD promocaoCRUD = new PromocaoCRUD();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/index.jsp?page=staff-promotions");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String ctx = req.getContextPath();
        if (!StaffAuth.isStaffLoggedIn(req)) {
            resp.sendRedirect(ctx + "/index.jsp?page=login");
            return;
        }
        if (!StaffAuth.hasPermission(req, "STAFF_PROMOTIONS")) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-dashboard&error=no-permission");
            return;
        }
        String action = req.getParameter("action");
        if (action == null || action.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-data");
            return;
        }
        try {
            switch (action) {
                case "create-promotion":
                    handleCreate(req, resp, ctx);
                    break;
                case "update-promotion":
                    handleUpdate(req, resp, ctx);
                    break;
                case "delete-promotion":
                    handleDelete(req, resp, ctx);
                    break;
                default:
                    resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-data");
            }
        } catch (Exception e) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-data");
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        String titulo = trim(req.getParameter("titulo"));
        String destino = trim(req.getParameter("destino"));
        String condicao = trim(req.getParameter("condicao"));
        String estado = trim(req.getParameter("estado"));
        LocalDate pi = parseDate(req.getParameter("periodo_inicio"));
        LocalDate pf = parseDate(req.getParameter("periodo_fim"));
        int idPacote = parseIntOrZero(req.getParameter("idPacote"));
        if (titulo.isEmpty() || destino.isEmpty() || estado.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-data&openCreate=1");
            return;
        }
        Promocao p = new Promocao(0, titulo, destino, pi, pf, condicao != null ? condicao : "", estado, idPacote);
        if (!promocaoCRUD.create(p)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-data&openCreate=1");
            return;
        }
        resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&success=promotion-created");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int id = Integer.parseInt(req.getParameter("idPromocao"));
        String titulo = trim(req.getParameter("titulo"));
        String destino = trim(req.getParameter("destino"));
        String condicao = trim(req.getParameter("condicao"));
        String estado = trim(req.getParameter("estado"));
        LocalDate pi = parseDate(req.getParameter("periodo_inicio"));
        LocalDate pf = parseDate(req.getParameter("periodo_fim"));
        int idPacote = parseIntOrZero(req.getParameter("idPacote"));
        if (titulo.isEmpty() || destino.isEmpty() || estado.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&selectedPromocao=" + id + "&error=invalid-data");
            return;
        }
        if (promocaoCRUD.findById(id) == null) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-data");
            return;
        }
        Promocao p = new Promocao(id, titulo, destino, pi, pf, condicao != null ? condicao : "", estado, idPacote);
        if (!promocaoCRUD.update(p)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&selectedPromocao=" + id + "&error=invalid-data");
            return;
        }
        resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&success=promotion-updated");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int id = Integer.parseInt(req.getParameter("idPromocao"));
        promocaoCRUD.deleteById(id);
        resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&success=promotion-deleted");
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
