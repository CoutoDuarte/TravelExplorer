package Connection.Servlets;

import Connection.Classes.FlightsSearchResult;
import Connection.Classes.PesquisaRequest;
import Connection.Classes.VooInfo;
import Connection.Security.StaffAuth;
import ExternalAPI.ApiConfig;
import ExternalAPI.FlightsClient;
import ExternalAPI.FlightsClient.FlightsApiException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/pesquisar")
public class PesquisaViagemServlet extends HttpServlet {

    private static final String ERRO_GERAL = "Não foi possível concluir a pesquisa neste momento.";
    private static final String ERRO_AUTH = "Para pesquisar viagens, precisa de iniciar sessão como cliente ou colaborador.";

    private final FlightsClient flights = new FlightsClient();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp);
    }

    private void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        boolean debug = isDebug(req);
        String debugStep = "read-params";
        String debugMessage = "";
        int flightsCount = 0;

        if (!BookingJsonHelper.isClienteLoggedIn(req) && !StaffAuth.isStaffLoggedIn(req)) {
            out.print(authRequiredJson());
            return;
        }

        PesquisaRequest pesquisa = PesquisaRequest.from(req);

        debugStep = "validate-params";
        String dateError = pesquisa.validateDates();
        if (dateError != null) {
            if (debug) {
                debugMessage = PesquisaRequest.messageForDateError(dateError);
            }
            out.print(errorJson(PesquisaRequest.messageForDateError(dateError), debug, debugStep, debugMessage, flightsCount));
            return;
        }
        if (!pesquisa.isValid()) {
            if (debug) {
                debugMessage = "Parâmetros obrigatórios em falta ou inválidos";
            }
            out.print(errorJson(ERRO_GERAL, debug, debugStep, debugMessage, flightsCount));
            return;
        }

        FlightsSearchResult flightResult;
        debugStep = "call-flights";
        try {
            flightResult = flights.pesquisarVoos(pesquisa);
            flightsCount = countFlights(flightResult);
        } catch (FlightsApiException e) {
            if (debug) {
                debugMessage = e.getDebugMessage();
            }
            out.print(errorJson(ERRO_GERAL, debug, debugStep, debugMessage, flightsCount));
            return;
        }

        List<VooInfo> voosIda = flightResult == null ? List.of() : flightResult.voosIda;
        List<VooInfo> voosRegresso = flightResult == null ? List.of() : flightResult.voosRegresso;

        debugStep = "build-json";
        out.print(successJson(pesquisa, voosIda, voosRegresso, debug, flightsCount));
    }

    private int countFlights(FlightsSearchResult result) {
        if (result == null) {
            return 0;
        }
        int count = result.voosIda == null ? 0 : result.voosIda.size();
        count += result.voosRegresso == null ? 0 : result.voosRegresso.size();
        return count;
    }

    private boolean isDebug(HttpServletRequest req) {
        return "1".equals(req.getParameter("debug"));
    }

    private String authRequiredJson() {
        return "{\"ok\":false,\"authRequired\":true,\"message\":\""
                + JsonUtil.escape(ERRO_AUTH) + "\"}";
    }

    private String successJson(PesquisaRequest p, List<VooInfo> ida, List<VooInfo> regresso,
                               boolean debug, int flightsCount) {
        StringBuilder json = new StringBuilder();
        json.append("{\"ok\":true");
        json.append(",\"origem\":\"").append(JsonUtil.escape(p.origem)).append("\"");
        json.append(",\"destino\":\"").append(JsonUtil.escape(p.destino)).append("\"");
        json.append(",\"dataPartida\":\"").append(JsonUtil.escape(p.dataPartida)).append("\"");
        json.append(",\"dataRegresso\":\"").append(JsonUtil.escape(p.dataRegresso)).append("\"");
        json.append(",\"adultos\":").append(p.adultos);
        json.append(",\"criancas\":").append(p.criancas);
        json.append(",\"voos\":").append(BookingJsonHelper.voosJson(ida));
        json.append(",\"voosIda\":").append(BookingJsonHelper.voosJson(ida));
        json.append(",\"voosRegresso\":").append(BookingJsonHelper.voosJson(regresso));
        json.append(",\"sugestao\":").append(BookingJsonHelper.nullSugestaoJson());
        json.append(",\"hoteisOpcoes\":").append(BookingJsonHelper.emptyHoteisJson());
        if (debug) {
            appendDebugFields(json, "build-json", "", flightsCount);
        }
        json.append("}");
        return json.toString();
    }

    private String errorJson(String message, boolean debug, String debugStep, String debugMessage, int flightsCount) {
        StringBuilder json = new StringBuilder();
        json.append("{\"ok\":false");
        json.append(",\"message\":\"").append(JsonUtil.escape(message != null ? message : ERRO_GERAL)).append("\"");
        if (debug) {
            appendDebugFields(json, debugStep, debugMessage, flightsCount);
        }
        json.append("}");
        return json.toString();
    }

    private void appendDebugFields(StringBuilder json, String debugStep, String debugMessage, int flightsCount) {
        json.append(",\"debugStep\":\"").append(JsonUtil.escape(debugStep)).append("\"");
        if (debugMessage != null && !debugMessage.isBlank()) {
            json.append(",\"debugMessage\":\"").append(JsonUtil.escape(debugMessage)).append("\"");
        }
        json.append(",\"serpApiKeyLoaded\":").append(ApiConfig.hasSerpAPIKey());
        json.append(",\"flightsCount\":").append(flightsCount);
    }
}
