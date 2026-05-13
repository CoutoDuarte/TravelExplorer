package Connection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String url = System.getenv().getOrDefault(
        "TRAVEL_DB_URL",
        "jdbc:mysql://127.0.0.1:3306/TravelExplorer?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
    );

    private static final String username = System.getenv().getOrDefault("TRAVEL_DB_USER", "root");
    private static final String password = System.getenv().getOrDefault("TRAVEL_DB_PASSWORD", "");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
}
