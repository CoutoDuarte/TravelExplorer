package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Alojamento;

public class AlojamentoCRUD {
	// CRUD - CREATE
	public void Insert(Alojamento alojamento) {
		String sql = "INSERT INTO ALOJAMENTO  (idAlojamento, nome, morada, num_pessoas, tipo_quarto, tipo_estadia, preco) VALUES (?, ?, ?, ?, ?, ?, ?)";

		try (Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql)) {
			stmt.setInt(1, alojamento.getIdAlojamento());
			stmt.setString(2, alojamento.getNome());
			stmt.setString(3, alojamento.getMorada());
			stmt.setInt(4, alojamento.getNumPessoas());
			stmt.setString(5, alojamento.getTipoQuarto());
			stmt.setString(6, alojamento.getTipoEstadia());
			stmt.setFloat(7, alojamento.getPreco());

			stmt.executeUpdate();
			System.out.println("Book inserted successfully!");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// CRUD - READ
	public List<Alojamento> getAllAlojamento() {

		List<Alojamento> alojamentos = new ArrayList<>();
		String sql = "SELECT * FROM ALOJAMENTO";

		try (Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql);
				ResultSet rs = stmt.executeQuery()) {

			while (rs.next()) {
				Alojamento alojamento = new Alojamento(
						rs.getInt("idAlojamento"),
						rs.getString("nome"),
						rs.getString("morada"),
						rs.getInt("num_pessoas"),
						rs.getString("tipo_quarto"),
						rs.getString("tipo_estadia"),
						rs.getFloat("preco"));

				alojamentos.add(alojamento);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return alojamentos;
	}

	public List<Alojamento> findAll() {
		return getAllAlojamento();
	}

	public boolean attachToPacote(int idPacote, int idAlojamento) {
		String sql = "INSERT IGNORE INTO PACOTE_ALOJAMENTO (idPacote, idAlojamento) VALUES (?, ?)";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql)) {
			stmt.setInt(1, idPacote);
			stmt.setInt(2, idAlojamento);
			return stmt.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	public boolean detachFromPacote(int idPacote, int idAlojamento) {
		String sql = "DELETE FROM PACOTE_ALOJAMENTO WHERE idPacote = ? AND idAlojamento = ?";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql)) {
			stmt.setInt(1, idPacote);
			stmt.setInt(2, idAlojamento);
			stmt.executeUpdate();
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	public boolean deleteAllAlojamentosForPacote(int idPacote) {
		String sql = "DELETE FROM PACOTE_ALOJAMENTO WHERE idPacote = ?";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql)) {
			stmt.setInt(1, idPacote);
			stmt.executeUpdate();
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	public List<Alojamento> findByPacote(int idPacote) {
		List<Alojamento> alojamentos = new ArrayList<>();
		String sql = "SELECT a.* FROM ALOJAMENTO a JOIN PACOTE_ALOJAMENTO pa ON pa.idAlojamento = a.idAlojamento WHERE pa.idPacote = ?";

		try (Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql)) {
			stmt.setInt(1, idPacote);
			try (ResultSet rs = stmt.executeQuery()) {
				while (rs.next()) {
					alojamentos.add(new Alojamento(
							rs.getInt("idAlojamento"),
							rs.getString("nome"),
							rs.getString("morada"),
							rs.getInt("num_pessoas"),
							rs.getString("tipo_quarto"),
							rs.getString("tipo_estadia"),
							rs.getFloat("preco")));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return alojamentos;
	}

	// CRUD - UPDATE
	public void Update(Alojamento alojamento) {
		String sql = "UPDATE ALOJAMENTO SET nome = ?, morada = ?, num_pessoas = ?, tipo_quarto = ?, tipo_estadia = ?, preco = ?  WHERE idAlojamento = ?";

		try (Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql)) {
			stmt.setInt(7, alojamento.getIdAlojamento());
			stmt.setString(1, alojamento.getNome());
			stmt.setString(2, alojamento.getMorada());
			stmt.setInt(3, alojamento.getNumPessoas());
			stmt.setString(4, alojamento.getTipoQuarto());
			stmt.setString(5, alojamento.getTipoEstadia());
			stmt.setFloat(6, alojamento.getPreco());

			stmt.executeUpdate();
			System.out.println("Client updated successfully!");
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	// CRUD - DELETE
	public void Delete(Alojamento alojamento) {
		String sql = "DELETE FROM ALOJAMENTO WHERE idAlojamento = ?";

		try (Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql)) {
			stmt.setInt(1, alojamento.getIdAlojamento());

			stmt.executeUpdate();
			System.out.println("Client deleted!");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
