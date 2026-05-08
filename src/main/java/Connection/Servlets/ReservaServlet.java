package Connection.Servlets;

import Connection.CRUD.ReservaCRUD;
import Connection.Classes.Reserva;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.util.List;
import java.time.LocalDate;

@WebServlet("/reservas")
public class ReservaServlet extends HttpServlet {

    private final ReservaCRUD dao = new ReservaCRUD();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String idParam = req.getParameter("id");

        if (idParam != null) {
            Reserva r = dao.findById(Integer.parseInt(idParam));
            if (r == null) { resp.setStatus(404); out.print("{\"error\":\"not found\"}"); return; }
            out.print(toJson(r));
        } else {
            List<Reserva> list = dao.findAll();
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < list.size(); i++) {
                if (i > 0) sb.append(",");
                sb.append(toJson(list.get(i)));
            }
            sb.append("]");
            out.print(sb);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        boolean ok = dao.insert(build(req));
        resp.setContentType("application/json");
        resp.getWriter().print("{\"success\":" + ok + "}");
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        boolean ok = dao.update(build(req));
        resp.setContentType("application/json");
        resp.getWriter().print("{\"success\":" + ok + "}");
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        boolean ok = dao.delete(id);
        resp.setContentType("application/json");
        resp.getWriter().print("{\"success\":" + ok + "}");
    }

    private Reserva build(HttpServletRequest req) {
        return new Reserva(
            Integer.parseInt(req.getParameter("idReserva")),
            LocalDate.parse(req.getParameter("data_reserva")),
            Float.parseFloat(req.getParameter("total_pagar")),
            req.getParameter("estado"),
            Integer.parseInt(req.getParameter("idCliente")),
            Integer.parseInt(req.getParameter("idPacote"))
        );
    }

    private String toJson(Reserva r) {
        return "{"
            + "\"idReserva\":" + r.getIdReserva() + ","
            + "\"dataReserva\":\"" + r.getDataReserva() + "\","
            + "\"totalPagar\":" + r.getTotalPagar() + ","
            + "\"estado\":\"" + JsonUtil.escape(r.getEstado()) + "\","
            + "\"idCliente\":" + r.getIdCliente() + ","
            + "\"idPacote\":" + r.getIdPacote()
            + "}";
    }
}