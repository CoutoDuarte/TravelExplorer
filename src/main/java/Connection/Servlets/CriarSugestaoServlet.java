package Connection.Servlets;

import Connection.Classes.CriarSugestaoRequest;
import Connection.Classes.SugestaoViagem;
import ExternalAPI.ApiConfig;
import ExternalAPI.OpenAIClient;
import ExternalAPI.OpenAIClient.IaeduParseDebug;
import ExternalAPI.OpenAIClient.OpenAiApiException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.stream.Collectors;

@WebServlet("/criar-sugestao")
public class CriarSugestaoServlet extends HttpServlet {

    private static final String ERRO_AUTH = "Para pesquisar e guardar viagens, precisa de iniciar sessão como cliente.";
    private static final String ERRO_GERAL = "Não foi possível criar a sugestão neste momento.";
    private static final String ERRO_PEDIDO = "Dados incompletos para criar a sugestão.";

    private final OpenAIClient openAI = new OpenAIClient();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        boolean debug = "1".equals(req.getParameter("debug"));

        if (!BookingJsonHelper.isClienteLoggedIn(req)) {
            out.print("{\"ok\":false,\"authRequired\":true,\"message\":\""
                    + JsonUtil.escape(ERRO_AUTH) + "\"}");
            return;
        }

        String body;
        try {
            body = req.getReader().lines().collect(Collectors.joining());
        } catch (Exception e) {
            out.print(errorJson(ERRO_PEDIDO, debug, "read-body", ""));
            return;
        }

        CriarSugestaoRequest pedido = CriarSugestaoRequest.fromJson(body);
        if (!pedido.isValid() || pedido.vooRegressoSelecionado == null) {
            out.print(errorJson(ERRO_PEDIDO, debug, "validate", ""));
            return;
        }

        SugestaoViagem sugestao;
        try {
            sugestao = openAI.gerarSugestaoFinal(pedido);
        } catch (OpenAiApiException e) {
            if (debug) {
                out.print(errorJson(ERRO_GERAL, true, "call-openai", e.getDebugMessage(), e));
                return;
            }
            sugestao = openAI.sugestaoFinalFallback(pedido);
        }

        StringBuilder json = new StringBuilder();
        json.append("{\"ok\":true");
        json.append(",\"sugestao\":").append(BookingJsonHelper.sugestaoJson(sugestao));
        if (debug) {
            IaeduParseDebug iaeduDebug = openAI.getLastIaeduDebug();
            json.append(",\"openAiKeyLoaded\":").append(ApiConfig.hasOpenAIKey());
            json.append(",\"openAiRawLength\":").append(iaeduDebug.rawLength);
            json.append(",\"openAiTextPreview\":\"").append(JsonUtil.escape(iaeduDebug.textPreview)).append("\"");
        }
        json.append("}");
        out.print(json.toString());
    }

    private String errorJson(String message, boolean debug, String step, String debugMessage) {
        return errorJson(message, debug, step, debugMessage, null);
    }

    private String errorJson(String message, boolean debug, String step, String debugMessage, OpenAiApiException e) {
        StringBuilder json = new StringBuilder();
        json.append("{\"ok\":false");
        json.append(",\"message\":\"").append(JsonUtil.escape(message)).append("\"");
        if (debug) {
            json.append(",\"debugStep\":\"").append(JsonUtil.escape(step)).append("\"");
            if (debugMessage != null && !debugMessage.isBlank()) {
                json.append(",\"debugMessage\":\"").append(JsonUtil.escape(debugMessage)).append("\"");
            }
            json.append(",\"openAiKeyLoaded\":").append(ApiConfig.hasOpenAIKey());
            if (e != null && e.getHttpStatus() > 0) {
                json.append(",\"openAiStatus\":").append(e.getHttpStatus());
            }
            if (e != null && e.getSanitizedBody() != null && !e.getSanitizedBody().isBlank()) {
                json.append(",\"openAiBody\":\"").append(JsonUtil.escape(e.getSanitizedBody())).append("\"");
            }
        }
        json.append("}");
        return json.toString();
    }
}
