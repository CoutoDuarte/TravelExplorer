package Connection.Servlets;

import Connection.Classes.AirportSuggestion;
import ExternalAPI.FlightAutocompleteClient;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/flight-autocomplete")
public class FlightAutocompleteServlet extends HttpServlet {

    private final FlightAutocompleteClient autocompleteClient = new FlightAutocompleteClient();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String q = req.getParameter("q");
        if (q == null || q.trim().length() < 2) {
            out.print("[]");
            return;
        }

        List<AirportSuggestion> airports = autocompleteClient.autocomplete(q.trim());
        out.print(toJsonArray(airports));
    }

    private String toJsonArray(List<AirportSuggestion> airports) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < airports.size(); i++) {
            if (i > 0) {
                json.append(',');
            }
            AirportSuggestion a = airports.get(i);
            json.append('{')
                .append("\"code\":\"").append(JsonUtil.escape(a.code)).append("\",")
                .append("\"name\":\"").append(JsonUtil.escape(a.name)).append("\",")
                .append("\"city\":\"").append(JsonUtil.escape(a.city)).append("\",")
                .append("\"label\":\"").append(JsonUtil.escape(a.label)).append("\"")
                .append('}');
        }
        json.append(']');
        return json.toString();
    }
}
