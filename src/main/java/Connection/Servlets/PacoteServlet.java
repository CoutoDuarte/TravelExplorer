package Connection.Servlets;

import Connection.CRUD.PacoteCRUD;
import Connection.Classes.Pacote;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/pacotes")
public class PacoteServlet extends HttpServlet {

    private final PacoteCRUD dao = new PacoteCRUD();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String idParam = req.getParameter("id");

        if (idParam != null) {
            Pacote p = dao.findById(Integer.parseInt(idParam));
            if (p == null) { resp.setStatus(404); out.print("{\"error\":\"not found\"}"); return; }
            out.print(toJson(p));
        } else {
            List<Pacote> list = dao.findAll();
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

    private Pacote build(HttpServletRequest req) {
        return new Pacote(
            Integer.parseInt(req.getParameter("idPacote")),
            req.getParameter("descricao"),
            req.getParameter("nome"),
            Float.parseFloat(req.getParameter("preco_base")),
            Integer.parseInt(req.getParameter("numero_pessoas_adultas")),
            Integer.parseInt(req.getParameter("numero_criancas")),
            Integer.parseInt(req.getParameter("idReserva"))
        );
    }

    private String toJson(Pacote p) {
        return "{"
            + "\"idPacote\":" + p.getIdPacote() + ","
            + "\"nome\":\"" + JsonUtil.escape(p.getNome()) + "\","
            + "\"descricao\":\"" + JsonUtil.escape(p.getDescricao()) + "\","
            + "\"precoBase\":" + p.getPrecoBase() + ","
            + "\"numeroPessoasAdultas\":" + p.getNumAdultos() + ","
            + "\"numeroCriancas\":" + p.getNumCriancas() + ","
            + "\"idReserva\":" + p.getIdReserva()
            + "}";
    }
}