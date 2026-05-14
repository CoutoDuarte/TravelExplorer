package Connection.Servlets;

import java.io.IOException;

import Connection.CRUD.AlojamentoCRUD;
import Connection.CRUD.PacoteCRUD;
import Connection.CRUD.TransporteCRUD;
import Connection.CRUD.ViagemCRUD;
import Connection.Classes.Pacote;
import Connection.Security.StaffAuth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/staff-offers")
public class StaffOffersServlet extends HttpServlet {

    private final PacoteCRUD pacoteCRUD = new PacoteCRUD();
    private final ViagemCRUD viagemCRUD = new ViagemCRUD();
    private final AlojamentoCRUD alojamentoCRUD = new AlojamentoCRUD();
    private final TransporteCRUD transporteCRUD = new TransporteCRUD();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/index.jsp?page=staff-offers");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String ctx = req.getContextPath();
        if (!StaffAuth.isStaffLoggedIn(req)) {
            resp.sendRedirect(ctx + "/index.jsp?page=login");
            return;
        }
        if (!StaffAuth.hasPermission(req, "STAFF_OFFERS")) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-dashboard&error=no-permission");
            return;
        }
        String action = req.getParameter("action");
        if (action == null || action.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&error=invalid-data");
            return;
        }
        try {
            switch (action) {
                case "create-package":
                    handleCreate(req, resp, ctx);
                    break;
                case "update-package":
                    handleUpdate(req, resp, ctx);
                    break;
                case "delete-package":
                    handleDelete(req, resp, ctx);
                    break;
                case "attach-viagem":
                    handleAttachViagem(req, resp, ctx);
                    break;
                case "detach-viagem":
                    handleDetachViagem(req, resp, ctx);
                    break;
                case "attach-alojamento":
                    handleAttachAlojamento(req, resp, ctx);
                    break;
                case "detach-alojamento":
                    handleDetachAlojamento(req, resp, ctx);
                    break;
                case "attach-transporte":
                    handleAttachTransporte(req, resp, ctx);
                    break;
                case "detach-transporte":
                    handleDetachTransporte(req, resp, ctx);
                    break;
                default:
                    resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&error=invalid-data");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&error=invalid-data");
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        String nome = trim(req.getParameter("nome"));
        String descricao = trim(req.getParameter("descricao"));
        String precoStr = trim(req.getParameter("preco_base"));
        String adultStr = trim(req.getParameter("numero_pessoas_adultas"));
        String criStr = trim(req.getParameter("numero_criancas"));
        if (nome.isEmpty() || descricao.isEmpty() || precoStr.isEmpty() || adultStr.isEmpty() || criStr.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&error=invalid-data");
            return;
        }
        float preco = Float.parseFloat(precoStr.replace(',', '.'));
        int adultos = Integer.parseInt(adultStr);
        int criancas = Integer.parseInt(criStr);
        if (preco < 0 || adultos < 0 || criancas < 0) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&error=invalid-data");
            return;
        }
        Pacote p = new Pacote(0, descricao, nome, preco, adultos, criancas, 0);
        if (!pacoteCRUD.create(p)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&error=invalid-data");
            return;
        }
        resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&success=package-created");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int idPacote = Integer.parseInt(req.getParameter("idPacote"));
        String nome = trim(req.getParameter("nome"));
        String descricao = trim(req.getParameter("descricao"));
        String precoStr = trim(req.getParameter("preco_base"));
        String adultStr = trim(req.getParameter("numero_pessoas_adultas"));
        String criStr = trim(req.getParameter("numero_criancas"));
        if (nome.isEmpty() || descricao.isEmpty() || precoStr.isEmpty() || adultStr.isEmpty() || criStr.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&selectedPacote=" + idPacote + "&error=invalid-data");
            return;
        }
        float preco = Float.parseFloat(precoStr.replace(',', '.'));
        int adultos = Integer.parseInt(adultStr);
        int criancas = Integer.parseInt(criStr);
        if (preco < 0 || adultos < 0 || criancas < 0) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&selectedPacote=" + idPacote + "&error=invalid-data");
            return;
        }
        Pacote existing = pacoteCRUD.findById(idPacote);
        if (existing == null) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&error=invalid-data");
            return;
        }
        Pacote updated = new Pacote(idPacote, descricao, nome, preco, adultos, criancas, existing.getIdReserva());
        if (!pacoteCRUD.update(updated)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&selectedPacote=" + idPacote + "&error=invalid-data");
            return;
        }
        resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&success=package-updated");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int idPacote = Integer.parseInt(req.getParameter("idPacote"));
        viagemCRUD.deleteAllViagensForPacote(idPacote);
        alojamentoCRUD.deleteAllAlojamentosForPacote(idPacote);
        transporteCRUD.deleteAllTransportesForPacote(idPacote);
        pacoteCRUD.deleteById(idPacote);
        resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&success=package-deleted");
    }

    private void handleAttachViagem(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int idPacote = Integer.parseInt(req.getParameter("idPacote"));
        int idViagem = Integer.parseInt(req.getParameter("idViagem"));
        viagemCRUD.attachToPacote(idPacote, idViagem);
        resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&selectedPacote=" + idPacote + "&success=relation-updated");
    }

    private void handleDetachViagem(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int idPacote = Integer.parseInt(req.getParameter("idPacote"));
        int idViagem = Integer.parseInt(req.getParameter("idViagem"));
        viagemCRUD.detachFromPacote(idPacote, idViagem);
        resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&selectedPacote=" + idPacote + "&success=relation-updated");
    }

    private void handleAttachAlojamento(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int idPacote = Integer.parseInt(req.getParameter("idPacote"));
        int idAlojamento = Integer.parseInt(req.getParameter("idAlojamento"));
        alojamentoCRUD.attachToPacote(idPacote, idAlojamento);
        resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&selectedPacote=" + idPacote + "&success=relation-updated");
    }

    private void handleDetachAlojamento(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int idPacote = Integer.parseInt(req.getParameter("idPacote"));
        int idAlojamento = Integer.parseInt(req.getParameter("idAlojamento"));
        alojamentoCRUD.detachFromPacote(idPacote, idAlojamento);
        resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&selectedPacote=" + idPacote + "&success=relation-updated");
    }

    private void handleAttachTransporte(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int idPacote = Integer.parseInt(req.getParameter("idPacote"));
        int idTransporte = Integer.parseInt(req.getParameter("idTransporte"));
        transporteCRUD.attachToPacote(idPacote, idTransporte);
        resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&selectedPacote=" + idPacote + "&success=relation-updated");
    }

    private void handleDetachTransporte(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        int idPacote = Integer.parseInt(req.getParameter("idPacote"));
        int idTransporte = Integer.parseInt(req.getParameter("idTransporte"));
        transporteCRUD.detachFromPacote(idPacote, idTransporte);
        resp.sendRedirect(ctx + "/index.jsp?page=staff-offers&selectedPacote=" + idPacote + "&success=relation-updated");
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
