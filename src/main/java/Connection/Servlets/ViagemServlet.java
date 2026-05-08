package Connection.Servlets;

import Connection.CRUD.ViagemCRUD;
import Connection.Classes.Viagens;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.util.List;

@WebServlet("/viagens")
public class ViagemServlet extends HttpServlet {

    private final ViagemCRUD dao = new ViagemCRUD();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String idParam = req.getParameter("id");

        if (idParam != null) {
            Viagens v = dao.findById(Integer.parseInt(idParam));
            if (v == null) {
                resp.setStatus(404);
                out.print("{\"error\":\"not found\"}");
                return;
            }
            out.print(toJson(v));
        } else {
            List<Viagens> list = dao.findAll();
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

    private Viagens build(HttpServletRequest req) {
        return new Viagens(
            Integer.parseInt(req.getParameter("idViagem")),
            Integer.parseInt(req.getParameter("numero_bilhetes_adulto")),
            Integer.parseInt(req.getParameter("numero_bilhetes_crianca")),
            Float.parseFloat(req.getParameter("preco")),
            req.getParameter("origem"),
            req.getParameter("destino"),
            parseTimestamp(req.getParameter("data_hora_partida")),
            parseTimestamp(req.getParameter("data_hora_regresso")),
            req.getParameter("descricao"),
            req.getParameter("empresa")
        );
    }

    // Aceita "yyyy-MM-dd HH:mm:ss" ou "yyyy-MM-ddTHH:mm" (formato HTML datetime-local)
    private Timestamp parseTimestamp(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        String normalized = s.replace("T", " ");
        if (normalized.length() == 16) normalized += ":00"; // adiciona segundos se faltarem
        return Timestamp.valueOf(normalized);
    }

    private String toJson(Viagens v) {
        return "{"
            + "\"idViagem\":" + v.getIdViagem() + ","
            + "\"numBilhetesAdulto\":" + v.getNumBilhetesAdulto() + ","
            + "\"numBilhetesCrianca\":" + v.getNumBilhetesCrianca() + ","
            + "\"preco\":" + v.getPreco() + ","
            + "\"origem\":\"" + JsonUtil.escape(v.getOrigem()) + "\","
            + "\"destino\":\"" + JsonUtil.escape(v.getDestino()) + "\","
            + "\"dataHoraPartida\":\"" + (v.getDataHoraPartida() != null ? v.getDataHoraPartida() : "") + "\","
            + "\"dataHoraRegresso\":\"" + (v.getDataHoraRegresso() != null ? v.getDataHoraRegresso() : "") + "\","
            + "\"descricao\":\"" + JsonUtil.escape(v.getDescricao()) + "\","
            + "\"empresa\":\"" + JsonUtil.escape(v.getEmpresa()) + "\""
            + "}";
    }
}