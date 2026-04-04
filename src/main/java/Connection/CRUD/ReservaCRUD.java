package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Reserva;

public class ReservaCRUD {
	//CRUD - CREATE
		public void Insert(Reserva reserva) {
			String sql = "INSERT INTO RESERVA (idReserva, data_reserva, total_pagar, estado, idCliente, idPacote) VALUES (?, ?, ?, ?, ?, ?)";
			
			try (Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
						stmt.setInt(1, reserva.getIdReserva());
						stmt.setDate(2, java.sql.Date.valueOf(reserva.getDataReserva()));
						stmt.setFloat(3, reserva.getTotalPagar());
						stmt.setString(4, reserva.getEstado());
						stmt.setInt(5, reserva.getIdCliente());
						stmt.setInt(6, reserva.getIdPacote());
						
						stmt.executeUpdate();
						System.out.println("Book inserted successfully!");
					}catch(Exception e) {
						e.printStackTrace();
					}
		}
		
		//CRUD - READ
		public List<Reserva> getAllReservas(){
			
			List<Reserva> reservas = new ArrayList<>();
			String sql = "SELECT * FROM RESERVA";
			
			try(Connection conn = DBConnection.getConnection();
					Statement stmt = conn.createStatement();
					ResultSet rs = stmt.executeQuery(sql)) {
					
					while (rs.next()) {
						Reserva reserva = new Reserva(
							rs.getInt("idReserva"),
							rs.getDate("data_reserva").toLocalDate(),
							rs.getFloat("total_pagar"),
							rs.getString("estado"),
							rs.getInt("idCliente"),
							rs.getInt("idPacote")
						);
						
						reservas.add(reserva);
					}
			}catch (Exception e) {
				e.printStackTrace();
			}
			
			return reservas;
		}
		
		//CRUD - UPDATE
		public void Update(Reserva reserva) {
			String sql = "UPDATE RESERVA SET data_reserva = ?, total_pagar = ?, estado = ?, idCliente = ?, idPacote = ?  WHERE idReserva = ?";
			
			try (Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
					stmt.setInt(6, reserva.getIdReserva());
					stmt.setDate(1, java.sql.Date.valueOf(reserva.getDataReserva()));
					stmt.setFloat(2, reserva.getTotalPagar());
					stmt.setString(3, reserva.getEstado());
					stmt.setInt(4, reserva.getIdCliente());
					stmt.setInt(5, reserva.getIdPacote());
					
					stmt.executeUpdate();
					System.out.println("Client updated successfully!");
				}catch(Exception e) {
					e.printStackTrace();
				}
			
		}
		
		//CRUD - DELETE
		public void Delete(Reserva reserva) {
			String sql = "DELETE FROM RESERVA WHERE idReserva = ?";
			
			try(Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
					stmt.setInt(1, reserva.getIdReserva());
					
					stmt.executeUpdate();
					System.out.println("Client deleted!");
			}catch(Exception e) {
				e.printStackTrace();
			}
		}
}

