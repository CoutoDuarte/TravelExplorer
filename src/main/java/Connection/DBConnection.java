package Connection;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    private static final String url = "jdbc:mysql://127.0.0.1:3306/TravelExplorer?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String username = "travel_user";
    private static final String password = "Root123!";

    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, username, password);
    }
}
