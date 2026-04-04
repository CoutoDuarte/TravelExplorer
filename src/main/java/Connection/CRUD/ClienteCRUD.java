package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Cliente;

public class ClienteCRUD {
	//CRUD - CREATE
		public void Insert(Cliente cliente) {
			String sql = "INSERT INTO CLIENTE (idCliente, nome, email, morada, NIF, telemovel, data_nascimento) VALUES (?, ?, ?, ?, ?, ?, ?)";
			
			try (Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
						stmt.setInt(1, cliente.getIdCliente());
						stmt.setString(2, cliente.getNome());
						stmt.setString(3, cliente.getEmail());
						stmt.setString(4, cliente.getMorada());
						stmt.setInt(5, cliente.getNIF());
						stmt.setInt(6, cliente.getTelemovel());
						stmt.setDate(7, java.sql.Date.valueOf(cliente.getDataNasc()));
						
						stmt.executeUpdate();
						System.out.println("Book inserted successfully!");
					}catch(Exception e) {
						e.printStackTrace();
					}
		}
		
		//CRUD - READ
		public List<Cliente> getAllCleintes(){
			
			List<Cliente> clientes = new ArrayList<>();
			String sql = "SELECT * FROM CLIENTE";
			
			try(Connection conn = DBConnection.getConnection();
					Statement stmt = conn.createStatement();
					ResultSet rs = stmt.executeQuery(sql)) {
					
					while (rs.next()) {
						Cliente cliente = new Cliente(
							rs.getInt("idCliente"),
							rs.getString("nome"),
							rs.getString("email"),
							rs.getString("morada"),
							rs.getInt("NIF"),
							rs.getInt("telemovel"),
							rs.getDate("data_nascimento").toLocalDate()
						);
						
						clientes.add(cliente);
					}
			}catch (Exception e) {
				e.printStackTrace();
			}
			
			return clientes;
		}
		
		//CRUD - UPDATE
		public void Update(Cliente cliente) {
			String sql = "UPDATE CLIENTE SET nome = ?, email = ?, morada = ?, NIF = ?, telemovel = ?, data_nascimento = ?  WHERE idCliente = ?";
			
			try (Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
					stmt.setInt(5, cliente.getIdCliente());
					stmt.setString(1, cliente.getNome());
					stmt.setString(2, cliente.getEmail());
					stmt.setString(3, cliente.getMorada());
					stmt.setInt(4, cliente.getNIF());
					stmt.setInt(5, cliente.getTelemovel());
					stmt.setDate(6, java.sql.Date.valueOf(cliente.getDataNasc()));
					
					stmt.executeUpdate();
					System.out.println("Client updated successfully!");
				}catch(Exception e) {
					e.printStackTrace();
				}
			
		}
		
		//CRUD - DELETE
		public void Delete(Cliente cliente) {
			String sql = "DELETE FROM CLIENTE WHERE idCliente = ?";
			
			try(Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
					stmt.setInt(1, cliente.getIdCliente());
					
					stmt.executeUpdate();
					System.out.println("Client deleted!");
			}catch(Exception e) {
				e.printStackTrace();
			}
		}
}
