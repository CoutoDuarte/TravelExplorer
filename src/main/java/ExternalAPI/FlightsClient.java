package ExternalAPI;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

public class FlightsClient {

    private final HttpClient http = HttpClient.newHttpClient();

    public String search(String origemIATA, String destinoIATA,
                         String dataPartida, String dataRegresso,
                         int adultos, int criancas) throws Exception {

        String url = "https://serpapi.com/search.json"
                + "?engine=google_flights"
                + "&departure_id=" + enc(origemIATA)
                + "&arrival_id="   + enc(destinoIATA)
                + "&outbound_date=" + enc(dataPartida)
                + "&return_date="   + enc(dataRegresso)
                + "&adults="    + adultos
                + "&children="  + criancas
                + "&currency=EUR"
                + "&hl=pt"
                + "&api_key=" + enc(ApiConfig.SERPAPI_KEY);

        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(30))
                .GET()
                .build();

        HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
        if (resp.statusCode() != 200) {
            throw new RuntimeException("SerpAPI error " + resp.statusCode() + ": " + resp.body());
        }
        return resp.body(); // JSON cru
    }

    private String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}