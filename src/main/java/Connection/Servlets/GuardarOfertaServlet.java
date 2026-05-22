package Connection.Servlets;

import Connection.CRUD.GuardarViagemCRUD;
import Connection.Classes.CriarSugestaoRequest;
import Connection.Classes.SugestaoViagem;
import Connection.Security.StaffAuth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.stream.Collectors;

@WebServlet("/guardar-oferta")
public class GuardarOfertaServlet extends HttpServlet {

    private static final String ERRO_AUTH = "Precisas de iniciar sessão como colaborador.";
    private static final String ERRO_PERMISSAO = "Não tens permissão para criar ofertas.";
    private static final String ERRO_GERAL = "Não foi possível guardar a oferta.";
    private static final String ERRO_PEDIDO = "Dados incompletos para guardar a oferta.";
    private static final String SUCESSO = "Oferta publicada com sucesso.";

    private final GuardarViagemCRUD guardarCRUD = new GuardarViagemCRUD();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        if (!StaffAuth.isStaffLoggedIn(req)) {
            out.print("{\"ok\":false,\"authRequired\":true,\"message\":\"" + JsonUtil.escape(ERRO_AUTH) + "\"}");
            return;
        }
        if (!StaffAuth.hasPermission(req, "STAFF_OFFERS")) {
            out.print("{\"ok\":false,\"permissionDenied\":true,\"message\":\"" + JsonUtil.escape(ERRO_PERMISSAO) + "\"}");
            return;
        }

        String body;
        try {
            body = req.getReader().lines().collect(Collectors.joining());
        } catch (Exception e) {
            out.print(errorJson(ERRO_PEDIDO));
            return;
        }

        CriarSugestaoRequest pedido = CriarSugestaoRequest.fromJson(body);
        SugestaoViagem sugestao = ensureSugestao(pedido, parseSugestao(body));

        if (!pedido.isValid() || pedido.vooRegressoSelecionado == null) {
            out.print(errorJson(ERRO_PEDIDO));
            return;
        }

        try {
            int idPacote = guardarCRUD.guardarOferta(pedido, sugestao);
            out.print("{\"ok\":true,\"idPacote\":" + idPacote + ",\"message\":\"" + JsonUtil.escape(SUCESSO) + "\"}");
        } catch (SQLException e) {
            e.printStackTrace();
            out.print(errorJson(ERRO_GERAL));
        } catch (Exception e) {
            e.printStackTrace();
            out.print(errorJson(ERRO_GERAL));
        }
    }

    private SugestaoViagem ensureSugestao(CriarSugestaoRequest pedido, SugestaoViagem sugestao) {
        if (sugestao != null) {
            return sugestao;
        }
        SugestaoViagem s = new SugestaoViagem();
        String origem = pedido.origem != null ? pedido.origem.trim() : "";
        String destino = pedido.destino != null ? pedido.destino.trim() : "";
        s.titulo = (!origem.isEmpty() && !destino.isEmpty()) ? origem + " → " + destino : "Oferta pública";
        s.descricao = "";
        s.hotelSugerido = pedido.hotelSelecionado != null && pedido.hotelSelecionado.nome != null
                ? pedido.hotelSelecionado.nome : "";
        s.transporteSugerido = "";
        s.precoEstimadoTotal = 0;
        return s;
    }

    private SugestaoViagem parseSugestao(String body) {
        String block = extractNestedObject(body, "sugestao");
        if (block.isBlank()) {
            return null;
        }
        return SugestaoViagem.fromJson(block);
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
