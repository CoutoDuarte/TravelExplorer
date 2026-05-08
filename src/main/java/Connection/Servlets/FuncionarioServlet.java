package Connection.Servlets;

import Connection.CRUD.FuncionarioCRUD;
import Connection.Classes.Funcionario;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/funcionarios")
public class FuncionarioServlet extends HttpServlet {

    private final FuncionarioCRUD dao = new FuncionarioCRUD();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String idParam = req.getParameter("id");

        if (idParam != null) {
            Funcionario f = dao.findById(Integer.parseInt(idParam));
            if (f == null) { resp.setStatus(404); out.print("{\"error\":\"not found\"}"); return; }
            out.print(toJson(f));
        } else {
            List<Funcionario> list = dao.findAll();
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

    private Funcionario build(HttpServletRequest req) {
        return new Funcionario(
            Integer.parseInt(req.getParameter("idFuncionario")),
            req.getParameter("nome"),
            req.getParameter("email"),
            Integer.parseInt(req.getParameter("telefone")),
            Float.parseFloat(req.getParameter("salario")),
            req.getParameter("password_hash")
        );
    }

    private String toJson(Funcionario f) {
        return "{"
            + "\"idFuncionario\":" + f.getIdFuncionario() + ","
            + "\"nome\":\"" + JsonUtil.escape(f.getNome()) + "\","
            + "\"email\":\"" + JsonUtil.escape(f.getEmail()) + "\","
            + "\"telefone\":" + f.getTelemovel() + ","
            + "\"salario\":" + f.getSalario()
            + "}";
    }
}