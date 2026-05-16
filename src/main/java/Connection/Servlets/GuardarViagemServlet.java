package Connection.Servlets;

import Connection.CRUD.GuardarViagemCRUD;
import Connection.Classes.CriarSugestaoRequest;
import Connection.Classes.SugestaoViagem;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.stream.Collectors;

@WebServlet("/guardar-viagem")
public class GuardarViagemServlet extends HttpServlet {

    private static final String ERRO_AUTH = "Precisas de iniciar sessão para guardar a viagem.";
    private static final String ERRO_GERAL = "Não foi possível guardar a viagem.";
    private static final String ERRO_PEDIDO = "Dados incompletos para guardar a viagem.";
    private static final String SUCESSO = "A tua reserva foi guardada com sucesso.";

    private final GuardarViagemCRUD guardarCRUD = new GuardarViagemCRUD();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        if (!BookingJsonHelper.isClienteLoggedIn(req)) {
            out.print("{\"ok\":false,\"authRequired\":true,\"message\":\"" + JsonUtil.escape(ERRO_AUTH) + "\"}");
            return;
        }

        Integer idCliente = getClienteId(req);
        if (idCliente == null) {
            out.print("{\"ok\":false,\"authRequired\":true,\"message\":\"" + JsonUtil.escape(ERRO_AUTH) + "\"}");
            return;
        }

        String body;
        try {
            body = req.getReader().lines().collect(Collectors.joining());
        } catch (Exception e) {
            e.printStackTrace();
            out.print(errorJson(ERRO_PEDIDO));
            return;
        }

        CriarSugestaoRequest pedido = CriarSugestaoRequest.fromJson(body);
        SugestaoViagem sugestao = parseSugestao(body);

        if (!pedido.isValid() || pedido.vooRegressoSelecionado == null || sugestao == null) {
            out.print(errorJson(ERRO_PEDIDO));
            return;
        }

        try {
            int idReserva = guardarCRUD.guardar(idCliente, pedido, sugestao);
            out.print("{\"ok\":true,\"idReserva\":" + idReserva + ",\"message\":\"" + JsonUtil.escape(SUCESSO) + "\"}");
        } catch (SQLException e) {
            e.printStackTrace();
            String detail = e.getMessage() != null ? e.getMessage() : ERRO_GERAL;
            out.print(errorJson(safeClientMessage(detail)));
        } catch (Exception e) {
            e.printStackTrace();
            out.print(errorJson(ERRO_GERAL));
        }
    }

    private SugestaoViagem parseSugestao(String body) {
        String block = extractNestedObject(body, "sugestao");
        if (block.isBlank()) {
            return null;
        }
        return SugestaoViagem.fromJson(block);
    }

    private Integer getClienteId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return null;
        }
        try {
            return Integer.valueOf(session.getAttribute("userId").toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String safeClientMessage(String detail) {
        if (detail == null || detail.isBlank()) {
            return ERRO_GERAL;
        }
        if (detail.length() > 180) {
            detail = detail.substring(0, 180) + "…";
        }
        return ERRO_GERAL + " (" + detail + ")";
    }

    private String errorJson(String message) {
        return "{\"ok\":false,\"message\":\"" + JsonUtil.escape(message) + "\"}";
    }

    private static String extractNestedObject(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) {
            return "";
        }
        int colon = json.indexOf(':', idx);
        if (colon < 0) {
            return "";
        }
        int i = colon + 1;
        while (i < json.length() && Character.isWhitespace(json.charAt(i))) {
            i++;
        }
        if (i >= json.length() || json.charAt(i) != '{') {
            return "";
        }
        int end = findObjectEnd(json, i);
        if (end < 0) {
            return "";
        }
        return json.substring(i, end + 1);
    }

    private static int findObjectEnd(String json, int start) {
        int depth = 0;
        boolean inString = false;
        boolean escape = false;
        for (int i = start; i < json.length(); i++) {
            char c = json.charAt(i);
            if (inString) {
                if (escape) {
                    escape = false;
                } else if (c == '\\') {
                    escape = true;
                } else if (c == '"') {
                    inString = false;
                }
                continue;
            }
            if (c == '"') {
                inString = true;
                continue;
            }
            if (c == '{') {
                depth++;
            } else if (c == '}') {
                depth--;
                if (depth == 0) {
                    return i;
                }
            }
        }
        return -1;
    }
}
