package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Pacote;

public class PacoteCRUD {

    // CREATE
    public boolean insert(Pacote pacote) {
        String sql = "INSERT INTO PACOTE (idPacote, descricao, nome, preco_base, "
                   + "numero_pessoas_adultas, numero_criancas, idReserva) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, pacote.getIdPacote());
            stmt.setString(2, pacote.getDescricao());
            stmt.setString(3, pacote.getNome());
            stmt.setFloat(4, pacote.getPrecoBase());
            stmt.setInt(5, pacote.getNumAdultos());
            stmt.setInt(6, pacote.getNumCriancas());
            stmt.setInt(7, pacote.getIdReserva());

            int rows = stmt.executeUpdate();
            System.out.println("Pacote inserted successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - todos
    public List<Pacote> getAllPacotes() {
        List<Pacote> pacotes = new ArrayList<>();
        String sql = "SELECT * FROM PACOTE";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                pacotes.add(map(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return pacotes;
    }

    public List<Pacote> findAll() {
        return getAllPacotes();
    }

    // READ - por ID
    public Pacote findById(int id) {
        String sql = "SELECT * FROM PACOTE WHERE idPacote = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public Pacote findByReserva(int idReserva) {
        String sql = "SELECT * FROM PACOTE WHERE idReserva = ? LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idReserva);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // UPDATE
    public boolean update(Pacote pacote) {
        String sql = "UPDATE PACOTE SET descricao = ?, nome = ?, preco_base = ?, "
                   + "numero_pessoas_adultas = ?, numero_criancas = ?, idReserva = ? "
                   + "WHERE idPacote = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, pacote.getDescricao());
            stmt.setString(2, pacote.getNome());
            stmt.setFloat(3, pacote.getPrecoBase());
            stmt.setInt(4, pacote.getNumAdultos());
            stmt.setInt(5, pacote.getNumCriancas());
            stmt.setInt(6, pacote.getIdReserva());
            stmt.setInt(7, pacote.getIdPacote());

            int rows = stmt.executeUpdate();
            System.out.println("Pacote updated successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE - por ID
    public boolean delete(int id) {
        String sql = "DELETE FROM PACOTE WHERE idPacote = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            int rows = stmt.executeUpdate();
            System.out.println("Pacote deleted!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Pacote pacote) {
        return delete(pacote.getIdPacote());
    }

    // Mapper privado
    private Pacote map(ResultSet rs) throws SQLException {
        return new Pacote(
            rs.getInt("idPacote"),
            rs.getString("descricao"),
            rs.getString("nome"),
            rs.getFloat("preco_base"),
            rs.getInt("numero_pessoas_adultas"),
            rs.getInt("numero_criancas"),
            rs.getInt("idReserva")
        );
    }
}