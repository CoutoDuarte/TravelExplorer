package Connection.Servlets;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import Connection.CRUD.ClienteOfertaGuardadaCRUD;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/ClienteOfertaGuardadaServlet")
public class ClienteOfertaGuardadaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Object userIdObj = session != null ? session.getAttribute("userId") : null;

        if (userIdObj == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp?page=login");
            return;
        }

        try {
            int idCliente = Integer.parseInt(userIdObj.toString());
            int idPacote = Integer.parseInt(req.getParameter("idPacote"));
            String action = req.getParameter("action");

            if ("remove".equals(action)) {
                ClienteOfertaGuardadaCRUD.removerOferta(idCliente, idPacote);
            } else if ("save".equals(action)) {
                ClienteOfertaGuardadaCRUD.guardarOferta(idCliente, idPacote);
            }

            resp.sendRedirect(req.getContextPath() + "/index.jsp?page=saved-offers");
        } catch (Exception e) {
            String error = URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Erro técnico", StandardCharsets.UTF_8.toString());
            resp.sendRedirect(req.getContextPath() + "/index.jsp?page=saved-offers&error=" + error);
        }
    }
}
