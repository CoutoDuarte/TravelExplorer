package Connection;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

	private static final String url = "jdbc:mysql://localhost:3306/TravelExplorer";
	private static final String username = "root";
	private static final String password = "Root123!";

	public static Connection getConnection() throws Exception {
		return DriverManager.getConnection(url, username, password);
	}
}
