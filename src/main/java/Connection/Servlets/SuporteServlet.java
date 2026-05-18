package Connection.Servlets;

import java.io.IOException;
import java.time.LocalDate;

import Connection.CRUD.ComunicacaoCRUD;
import Connection.CRUD.ReservaCRUD;
import Connection.Classes.Comunicacao;
import Connection.Classes.Reserva;
import Connection.Security.StaffAuth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/suporte")
public class SuporteServlet extends HttpServlet {

    private final ComunicacaoCRUD comunicacaoCRUD = new ComunicacaoCRUD();
    private final ReservaCRUD reservaCRUD = new ReservaCRUD();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String ctx = req.getContextPath();
        String action = trim(req.getParameter("action"));
        if ("contact".equals(action)) {
            handleContact(req, resp, ctx);
        } else if ("answer".equals(action)) {
            handleAnswer(req, resp, ctx);
        } else {
            resp.sendRedirect(ctx + "/index.jsp?page=my-reservations");
        }
    }

    private void handleContact(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
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
        Comunicacao existing = comunicacaoCRUD.findByReserva(idReserva);
        if (existing != null) {
            resp.sendRedirect(ctx + "/index.jsp?page=reservation-details&idReserva=" + idReserva);
            return;
        }
        String mensagem = trim(req.getParameter("mensagem"));
        if (mensagem.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=reservation-details&idReserva=" + idReserva + "&error=empty-message");
            return;
        }
        Comunicacao c = new Comunicacao(
            0,
            "Pedido sobre reserva #" + idReserva,
            "Área de Cliente",
            "Reserva",
            LocalDate.now(),
            "Aberto",
            mensagem,
            idCliente,
            idReserva,
            null,
            null,
            0
        );
        if (!comunicacaoCRUD.createSupport(c)) {
            resp.sendRedirect(ctx + "/index.jsp?page=reservation-details&idReserva=" + idReserva + "&error=send-failed");
            return;
        }
        resp.sendRedirect(ctx + "/index.jsp?page=reservation-details&idReserva=" + idReserva + "&success=support-sent");
    }

    private void handleAnswer(HttpServletRequest req, HttpServletResponse resp, String ctx) throws IOException {
        if (!StaffAuth.isStaffLoggedIn(req)) {
            resp.sendRedirect(ctx + "/index.jsp?page=login");
            return;
        }
        if (!StaffAuth.hasPermission(req, "STAFF_COMMUNICATION")) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-dashboard&error=no-permission");
            return;
        }
        int idComunicacao;
        try {
            idComunicacao = Integer.parseInt(req.getParameter("idComunicacao"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&error=invalid-data");
            return;
        }
        Comunicacao existing = comunicacaoCRUD.findById(idComunicacao);
        if (existing == null) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&error=invalid-data");
            return;
        }
        if (existing.getResposta() != null && !existing.getResposta().trim().isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&selectedComunicacao=" + idComunicacao);
            return;
        }
        String resposta = trim(req.getParameter("resposta"));
        if (resposta.isEmpty()) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&selectedComunicacao=" + idComunicacao + "&error=invalid-data");
            return;
        }
        Object staffIdObj = req.getSession().getAttribute("userId");
        int idFuncionario = staffIdObj != null ? Integer.parseInt(staffIdObj.toString()) : 0;
        if (!comunicacaoCRUD.answerSupport(idComunicacao, resposta, idFuncionario)) {
            resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&selectedComunicacao=" + idComunicacao + "&error=invalid-data");
            return;
        }
        resp.sendRedirect(ctx + "/index.jsp?page=staff-communication&success=support-answered");
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
