package Connection.Servlets;

import Connection.CRUD.ClienteCRUD;
import Connection.Classes.Cliente;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/clientes")
public class ClienteServlet extends HttpServlet {

    private final ClienteCRUD dao = new ClienteCRUD();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String idParam = req.getParameter("id");

        if (idParam != null) {
            Cliente c = dao.findById(Integer.parseInt(idParam));
            if (c == null) {
                resp.setStatus(404);
                out.print("{\"error\":\"not found\"}");
                return;
            }
            out.print(toJson(c));
        } else {
            List<Cliente> list = dao.findAll();
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
        Cliente c = build(req);
        boolean ok = dao.insert(c);
        resp.setContentType("application/json");
        resp.getWriter().print("{\"success\":" + ok + "}");
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Cliente c = build(req);
        boolean ok = dao.update(c);
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

    private Cliente build(HttpServletRequest req) {
        String passwordHash = req.getParameter("password_hash");

        Cliente c = new Cliente(
            Integer.parseInt(req.getParameter("idCliente")),
            req.getParameter("nome"),
            req.getParameter("email"),
            req.getParameter("morada"),
            Integer.parseInt(req.getParameter("NIF")),
            Integer.parseInt(req.getParameter("telemovel")),
            LocalDate.parse(req.getParameter("data_nascimento")), // formato yyyy-MM-dd
            passwordHash
        );
        return c;
    }

    private String toJson(Cliente c) {
        return "{"
            + "\"idCliente\":" + c.getIdCliente() + ","
            + "\"nome\":\"" + JsonUtil.escape(c.getNome()) + "\","
            + "\"email\":\"" + JsonUtil.escape(c.getEmail()) + "\","
            + "\"morada\":\"" + JsonUtil.escape(c.getMorada()) + "\","
            + "\"NIF\":" + c.getNIF() + ","
            + "\"telemovel\":" + c.getTelemovel() + ","
            + "\"data_nascimento\":\"" + c.getDataNasc() + "\""
            + "}";
    }
}