package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Pacote;

public class PacoteCRUD {
	//CRUD - CREATE
		public void Insert(Pacote pacote) {
			String sql = "INSERT INTO PACOTE (idPacote, descricao, nome, preco_base, numero_pessoas_adultas, numero_criancas, idReserva) VALUES (?, ?, ?, ?, ?, ?, ?)";
			
			try (Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
						stmt.setInt(1, pacote.getIdPacote());
						stmt.setString(2, pacote.getDescricao());
						stmt.setString(3, pacote.getNome());
						stmt.setFloat(4, pacote.getPrecoBase());
						stmt.setInt(5, pacote.getNumAdultos());
						stmt.setInt(6, pacote.getNumCriancas());
						stmt.setInt(7, pacote.getIdReserva());
						
						stmt.executeUpdate();
						System.out.println("Book inserted successfully!");
					}catch(Exception e) {
						e.printStackTrace();
					}
		}
		
		//CRUD - READ
		public List<Pacote> getAllPacotes(){
			
			List<Pacote> pacotes = new ArrayList<>();
			String sql = "SELECT * FROM PACOTE";
			
			try(Connection conn = DBConnection.getConnection();
					Statement stmt = conn.createStatement();
					ResultSet rs = stmt.executeQuery(sql)) {
					
					while (rs.next()) {
						Pacote pacote = new Pacote(
							rs.getInt("idPacote"),
							rs.getString("descricao"),
							rs.getString("nome"),
							rs.getFloat("preco_base"),
							rs.getInt("numero_pessoas_adultas"),
							rs.getInt("numero_criancas"),
							rs.getInt("idReserva")
						);
						
						pacotes.add(pacote);
					}
			}catch (Exception e) {
				e.printStackTrace();
			}
			
			return pacotes;
		}
		
		//CRUD - UPDATE
		public void Update(Pacote pacote) {
			String sql = "UPDATE PACOTE SET descricao = ?, nome = ?, preco_base = ?, numero_pessoas_adultas = ?, numero_criancas = ?, idReserva = ?  WHERE idPacote = ?";
			
			try (Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
					stmt.setInt(7, pacote.getIdPacote());
					stmt.setString(1, pacote.getDescricao());
					stmt.setString(2, pacote.getNome());
					stmt.setFloat(3, pacote.getPrecoBase());
					stmt.setInt(4, pacote.getNumAdultos());
					stmt.setInt(5, pacote.getNumCriancas());
					stmt.setInt(6, pacote.getIdReserva());
					
					stmt.executeUpdate();
					System.out.println("Client updated successfully!");
				}catch(Exception e) {
					e.printStackTrace();
				}
			
		}
		
		//CRUD - DELETE
		public void Delete(Pacote pacote) {
			String sql = "DELETE FROM PACOTE WHERE idPacote = ?";
			
			try(Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
					stmt.setInt(1, pacote.getIdPacote());
					
					stmt.executeUpdate();
					System.out.println("Client deleted!");
			}catch(Exception e) {
				e.printStackTrace();
			}
		}
}


