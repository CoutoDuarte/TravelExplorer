package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Funcionario;

public class FuncionarioCRUD {
	//CRUD - CREATE
		public void Insert(Funcionario func) {
			String sql = "INSERT INTO FUNCIONARIO (idFuncionario, nome, email, telefone, salario) VALUES (?, ?, ?, ?, ?)";
			
			try (Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
						stmt.setInt(1, func.getIdFuncionario());
						stmt.setString(2, func.getNome());
						stmt.setString(3, func.getEmail());
						stmt.setInt(4, func.getTelemovel());
						stmt.setFloat(5, func.getSalario());
						
						stmt.executeUpdate();
						System.out.println("Book inserted successfully!");
					}catch(Exception e) {
						e.printStackTrace();
					}
		}
		
		//CRUD - READ
		public List<Funcionario> getAllFuncionarios(){
			
			List<Funcionario> funcionarios = new ArrayList<>();
			String sql = "SELECT * FROM FUNCIONARIO";
			
			try(Connection conn = DBConnection.getConnection();
					Statement stmt = conn.createStatement();
					ResultSet rs = stmt.executeQuery(sql)) {
					
					while (rs.next()) {
						Funcionario funcionario = new Funcionario(
							rs.getInt("idFuncionario"),
							rs.getString("nome"),
							rs.getString("email"),
							rs.getInt("telemovel"),
							rs.getFloat("salario")
						);
						
						funcionarios.add(funcionario);
					}
			}catch (Exception e) {
				e.printStackTrace();
			}
			
			return funcionarios;
		}
		
		//CRUD - UPDATE
		public void Update(Funcionario func) {
			String sql = "UPDATE FUNCIONARIO SET nome = ?, email = ?, telemovel = ?, salario = ?  WHERE idFuncionario = ?";
			
			try (Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
					stmt.setInt(5, func.getIdFuncionario());
					stmt.setString(1, func.getNome());
					stmt.setString(2, func.getEmail());
					stmt.setInt(3, func.getTelemovel());
					stmt.setFloat(4, func.getSalario());
					
					stmt.executeUpdate();
					System.out.println("Client updated successfully!");
				}catch(Exception e) {
					e.printStackTrace();
				}
			
		}
		
		//CRUD - DELETE
		public void Delete(Funcionario func) {
			String sql = "DELETE FROM FUNCIONARIO WHERE idFuncionario= ?";
			
			try(Connection conn = DBConnection.getConnection();
					PreparedStatement stmt = conn.prepareStatement(sql)){
					stmt.setInt(1, func.getIdFuncionario());
					
					stmt.executeUpdate();
					System.out.println("Client deleted!");
			}catch(Exception e) {
				e.printStackTrace();
			}
		}
}

