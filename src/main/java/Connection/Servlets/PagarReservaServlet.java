package Connection.Servlets;

import java.io.IOException;

import Connection.CRUD.ClienteCRUD;
import Connection.CRUD.PagamentoCRUD;
import Connection.CRUD.ReservaCRUD;
import Connection.Classes.Cliente;
import Connection.Classes.Pagamento;
import Connection.Classes.Reserva;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/pagar-reserva")
public class PagarReservaServlet extends HttpServlet {

    private final ReservaCRUD reservaCRUD = new ReservaCRUD();
    private final PagamentoCRUD pagamentoCRUD = new PagamentoCRUD();
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
        int idReserva;
        try {
            idReserva = Integer.parseInt(req.getParameter("idReserva"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(ctx + "/index.jsp?page=my-reservations&error=invalid-data");
            return;
        }
        Reserva reserva = reservaCRUD.findByIdAndCliente(idReserva, idCliente);
        if (reserva == null) {
            resp.sendRedirect(ctx + "/index.jsp?page=my-reservations&error=not-found");
            return;
        }
        Cliente cliente = clienteCRUD.findById(idCliente);
        if (cliente == null || !cliente.hasBillingComplete()) {
            resp.sendRedirect(ctx + "/index.jsp?page=billing-details&idReserva=" + idReserva + "&returnTo=pay");
            return;
        }
        if (!cliente.isAtLeast18()) {
            resp.sendRedirect(ctx + "/index.jsp?page=pay-reservation&idReserva=" + idReserva + "&error=underage");
            return;
        }
        Pagamento pagamento = pagamentoCRUD.findFirstByReserva(idReserva);
        if (pagamento == null) {
            resp.sendRedirect(ctx + "/index.jsp?page=my-reservations&error=no-payment");
            return;
        }
        String estado = pagamento.getEstado();
        if (estado != null && "Pago".equalsIgnoreCase(estado.trim())) {
            resp.sendRedirect(ctx + "/index.jsp?page=reservation-details&idReserva=" + idReserva);
            return;
        }
        String metodo = trim(req.getParameter("metodo"));
        if (metodo.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=pay-reservation&idReserva=" + idReserva + "&error=invalid-data");
            return;
        }
        String referencia = "TE-" + idReserva + "-" + System.currentTimeMillis();
        if (!pagamentoCRUD.markAsPaid(pagamento.getIdPagamento(), idCliente, idReserva, metodo, referencia)) {
            resp.sendRedirect(ctx + "/index.jsp?page=pay-reservation&idReserva=" + idReserva + "&error=payment-failed");
            return;
        }
        reservaCRUD.updateEstado(idReserva, idCliente, "Confirmada");
        resp.sendRedirect(ctx + "/index.jsp?page=reservation-details&idReserva=" + idReserva + "&payment=success");
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
