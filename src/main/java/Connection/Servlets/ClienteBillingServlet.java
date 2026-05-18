package Connection.Servlets;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

import Connection.CRUD.ClienteCRUD;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cliente-billing")
public class ClienteBillingServlet extends HttpServlet {

    private final ClienteCRUD clienteCRUD = new ClienteCRUD();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String ctx = req.getContextPath();
        HttpSession session = req.getSession(false);
        if (!isCliente(session)) {
            resp.sendRedirect(ctx + "/index.jsp?page=login");
            return;
        }
        int idCliente = Integer.parseInt(session.getAttribute("userId").toString());
        String morada = trim(req.getParameter("morada"));
        String nifStr = trim(req.getParameter("nif"));
        String dataStr = trim(req.getParameter("data_nascimento"));
        String returnTo = trim(req.getParameter("returnTo"));
        String idReservaParam = trim(req.getParameter("idReserva"));
        if (morada.isEmpty() || nifStr.isEmpty() || dataStr.isEmpty()) {
            resp.sendRedirect(buildRedirect(ctx, returnTo, idReservaParam, "invalid-data"));
            return;
        }
        int nif;
        LocalDate dataNasc;
        try {
            nif = Integer.parseInt(nifStr);
            dataNasc = LocalDate.parse(dataStr);
        } catch (NumberFormatException | DateTimeParseException e) {
            resp.sendRedirect(buildRedirect(ctx, returnTo, idReservaParam, "invalid-data"));
            return;
        }
        if (nif <= 0) {
            resp.sendRedirect(buildRedirect(ctx, returnTo, idReservaParam, "invalid-data"));
            return;
        }
        if (!clienteCRUD.updateBilling(idCliente, morada, nif, dataNasc)) {
            resp.sendRedirect(buildRedirect(ctx, returnTo, idReservaParam, "save-failed"));
            return;
        }
        if ("pay".equals(returnTo)) {
            String idReserva = trim(req.getParameter("idReserva"));
            if (!idReserva.isEmpty()) {
                resp.sendRedirect(ctx + "/index.jsp?page=pay-reservation&idReserva=" + idReserva);
                return;
            }
        }
        resp.sendRedirect(ctx + "/index.jsp?page=profile&success=billing-updated");
    }

    private static String buildRedirect(String ctx, String returnTo, String idReserva, String error) {
        String base = ctx + "/index.jsp?page=billing-details&error=" + error;
        if (idReserva != null && !idReserva.isEmpty()) {
            base += "&idReserva=" + idReserva + "&returnTo=" + (returnTo != null ? returnTo : "");
        }
        return base;
    }

    private static boolean isCliente(HttpSession session) {
        return session != null
                && Boolean.TRUE.equals(session.getAttribute("auth"))
                && "cliente".equals(session.getAttribute("userType"))
                && session.getAttribute("userId") != null;
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
