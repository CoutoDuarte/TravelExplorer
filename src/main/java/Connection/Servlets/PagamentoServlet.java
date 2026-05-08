package Connection.Servlets;

import Connection.CRUD.PagamentoCRUD;
import Connection.Classes.Pagamento;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.util.List;

@WebServlet("/pagamentos")
public class PagamentoServlet extends HttpServlet {

    private final PagamentoCRUD dao = new PagamentoCRUD();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String idParam = req.getParameter("id");

        if (idParam != null) {
            Pagamento p = dao.findById(Integer.parseInt(idParam));
            if (p == null) { resp.setStatus(404); out.print("{\"error\":\"not found\"}"); return; }
            out.print(toJson(p));
        } else {
            List<Pagamento> list = dao.findAll();
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

    private Pagamento build(HttpServletRequest req) {
        return new Pagamento(
            Integer.parseInt(req.getParameter("idPagamento")),
            Float.parseFloat(req.getParameter("valor")),
            req.getParameter("metodo"),
            Date.valueOf(req.getParameter("data_pagamento")),
            Integer.parseInt(req.getParameter("idCliente")),
            Integer.parseInt(req.getParameter("idReserva"))
        );
    }

    private String toJson(Pagamento p) {
        return "{"
            + "\"idPagamento\":" + p.getIdPagamento() + ","
            + "\"valor\":" + p.getValor() + ","
            + "\"metodo\":\"" + JsonUtil.escape(p.getMetodo()) + "\","
            + "\"dataPagamento\":\"" + p.getDataPagamento() + "\","
            + "\"idCliente\":" + p.getIdCliente() + ","
            + "\"idReserva\":" + p.getIdReserva()
            + "}";
    }
}