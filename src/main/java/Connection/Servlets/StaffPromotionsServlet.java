package Connection.Servlets;

import java.io.IOException;
import java.time.LocalDate;

import Connection.CRUD.PacoteCRUD;
import Connection.CRUD.PromocaoCRUD;
import Connection.Classes.Pacote;
import Connection.PacotePublicHelper;
import Connection.Classes.Promocao;
import Connection.Security.StaffAuth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/staff-promotions")
public class StaffPromotionsServlet extends HttpServlet {

    private final PromocaoCRUD promocaoCRUD = new PromocaoCRUD();
    private final PacoteCRUD pacoteCRUD = new PacoteCRUD();

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
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-action");
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
                    resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=save-failed&openCreate=1");
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int idPacote = parseIntOrZero(req.getParameter("idPacote"));
        if (idPacote <= 0) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=missing-pacote&openCreate=1");
            return;
        }
        Pacote pacote = pacoteCRUD.findById(idPacote);
        if (pacote == null || !PacotePublicHelper.isPubliclyVisible(pacote)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-pacote&openCreate=1");
            return;
        }
        LocalDate pi = parseDate(req.getParameter("periodo_inicio"));
        LocalDate pf = parseDate(req.getParameter("periodo_fim"));
        if (pi == null || pf == null) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=missing-dates&openCreate=1");
            return;
        }
        if (pf.isBefore(pi)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-dates&openCreate=1");
            return;
        }
        double desconto = parseDoubleOrZero(req.getParameter("desconto_percent"));
        if (desconto <= 0 || desconto >= 100) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=invalid-discount&openCreate=1");
            return;
        }
        String titulo = trim(req.getParameter("titulo"));
        String destino = trim(req.getParameter("destino"));
        String estado = trim(req.getParameter("estado"));
        if (titulo.isEmpty()) {
            titulo = "Promoção — " + (pacote.getNome() != null ? pacote.getNome().trim() : "Oferta");
        }
        if (destino.isEmpty()) {
            destino = pacote.getNome() != null && !pacote.getNome().isBlank()
                    ? pacote.getNome().trim()
                    : "Oferta TravelExplorer";
        }
        if (estado.isEmpty()) {
            estado = "Ativa";
        }
        String condicao = trim(req.getParameter("condicao"));
        if (condicao.isEmpty()) {
            condicao = "Desconto de " + (int) Math.round(desconto) + "% sobre o preço base do pacote.";
        }
        Promocao p = new Promocao(0, titulo, destino, pi, pf, condicao, estado, idPacote);
        if (!promocaoCRUD.create(p)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=save-failed&openCreate=1");
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
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&selectedPromocao=" + id + "&error=missing-fields");
            return;
        }
        if (promocaoCRUD.findById(id) == null) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&error=not-found");
            return;
        }
        Promocao p = new Promocao(id, titulo, destino, pi, pf, condicao != null ? condicao : "", estado, idPacote);
        if (!promocaoCRUD.update(p)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-promotions&selectedPromocao=" + id + "&error=save-failed");
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

    private static double parseDoubleOrZero(String s) {
        String t = trim(s);
        if (t.isEmpty()) {
            return 0;
        }
        return Double.parseDouble(t.replace(',', '.'));
    }
}
