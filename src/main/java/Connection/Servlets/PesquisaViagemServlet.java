package Connection.Servlets;

import ExternalAPI.OpenAIClient;
import ExternalAPI.FlightsClient;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/pesquisar")
public class PesquisaViagemServlet extends HttpServlet {

    private final OpenAIClient openAI = new OpenAIClient();
    private final FlightsClient flights = new FlightsClient();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            String origem    = req.getParameter("origem");
            String destino   = req.getParameter("destino");
            String dataIda   = req.getParameter("data_partida");
            String dataVolta = req.getParameter("data_regresso");
            int adultos      = Integer.parseInt(req.getParameter("adultos"));
            int criancas     = Integer.parseInt(req.getParameter("criancas"));

            // 1. ChatGPT → contexto (IATA + alojamento + transfer)
            String contextoJson = openAI.pesquisarContexto(
                    origem, destino, adultos, criancas, dataIda, dataVolta);

            // 2. Extrai IATA do JSON do ChatGPT (parse simples)
            String origemIATA  = extractField(contextoJson, "origemIATA");
            String destinoIATA = extractField(contextoJson, "destinoIATA");

            // 3. Pesquisa voos reais
            String voosJson = flights.search(
                    origemIATA, destinoIATA, dataIda, dataVolta, adultos, criancas);

            // 4. Combina e devolve
            String combined = "{"
                    + "\"contexto\":" + contextoJson + ","
                    + "\"voos\":"     + voosJson
                    + "}";

            out.print(combined);

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    /** Parse muito simples — substitui por Gson se possível */
    private String extractField(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) return "";
        int colon = json.indexOf(':', idx);
        int start = json.indexOf('"', colon) + 1;
        int end   = json.indexOf('"', start);
        return json.substring(start, end);
    }
}