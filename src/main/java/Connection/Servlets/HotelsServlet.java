package Connection.Servlets;

import Connection.Classes.HotelSugestao;
import Connection.Classes.PesquisaRequest;
import ExternalAPI.ApiConfig;
import ExternalAPI.HotelsClient;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/hotels")
public class HotelsServlet extends HttpServlet {

    private static final String ERRO_AUTH = "Para pesquisar e guardar viagens, precisa de iniciar sessão como cliente.";
    private static final String ERRO_HOTELS = "Não foi possível carregar alojamentos neste momento.";

    private final HotelsClient hotelsClient = new HotelsClient();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        if (!BookingJsonHelper.canUseTravelWizard(req)) {
            out.print("{\"ok\":false,\"authRequired\":true,\"message\":\""
                    + JsonUtil.escape(ERRO_AUTH) + "\"}");
            return;
        }

        PesquisaRequest pesquisa = PesquisaRequest.from(req);
        if (pesquisa.origem == null || pesquisa.origem.isBlank()) {
            pesquisa.origem = pesquisa.destino;
        }

        boolean debug = "1".equals(req.getParameter("debug"));

        if (!pesquisa.isValid()) {
            out.print("{\"ok\":false,\"message\":\"" + JsonUtil.escape(ERRO_HOTELS) + "\"}");
            return;
        }

        List<HotelSugestao> hoteis;
        try {
            hoteis = hotelsClient.pesquisarHotels(pesquisa);
        } catch (Exception e) {
            out.print(errorJson(debug, hotelsClient, ERRO_HOTELS));
            return;
        }

        if (hoteis == null || hoteis.isEmpty()) {
            out.print(errorJson(debug, hotelsClient, ERRO_HOTELS));
            return;
        }

        StringBuilder json = new StringBuilder();
        json.append("{\"ok\":true");
        json.append(",\"hoteisOpcoes\":").append(BookingJsonHelper.hoteisOpcoesJson(hoteis));
        if (debug) {
            json.append(",\"hotelsCount\":").append(hotelsClient.getLastHotelCount());
            json.append(",\"hotelsProvider\":\"").append(JsonUtil.escape("serpapi_google_hotels")).append("\"");
            json.append(",\"hotelDebugMessage\":\"").append(JsonUtil.escape(hotelsClient.getLastHotelDebugMessage())).append("\"");
            json.append(",\"serpApiKeyLoaded\":").append(ApiConfig.hasSerpAPIKey());
        }
        json.append("}");
        out.print(json.toString());
    }

    private String errorJson(boolean debug, HotelsClient hc, String message) {
        StringBuilder json = new StringBuilder();
        json.append("{\"ok\":false");
        json.append(",\"message\":\"").append(JsonUtil.escape(message)).append("\"");
        if (debug && hc != null) {
            json.append(",\"hotelsCount\":").append(hc.getLastHotelCount());
            json.append(",\"hotelDebugMessage\":\"").append(JsonUtil.escape(hc.getLastHotelDebugMessage())).append("\"");
            json.append(",\"serpApiKeyLoaded\":").append(ApiConfig.hasSerpAPIKey());
        }
        json.append("}");
        return json.toString();
    }
}
