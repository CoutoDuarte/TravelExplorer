package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Pacote;

public class PacoteCRUD {

    private void setIdReserva(PreparedStatement stmt, int index, int idReserva) throws SQLException {
        if (idReserva <= 0) {
            stmt.setNull(index, Types.INTEGER);
        } else {
            stmt.setInt(index, idReserva);
        }
    }

    public int getNextId() {
        String sql = "SELECT COALESCE(MAX(idPacote), 0) + 1 FROM PACOTE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 1;
    }

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
            setIdReserva(stmt, 7, pacote.getIdReserva());

            int rows = stmt.executeUpdate();
            System.out.println("Pacote inserted successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean create(Pacote pacote) {
        int id = getNextId();
        Pacote row = new Pacote(
            id,
            pacote.getDescricao(),
            pacote.getNome(),
            pacote.getPrecoBase(),
            pacote.getNumAdultos(),
            pacote.getNumCriancas(),
            pacote.getIdReserva()
        );
        return insert(row);
    }

    public List<Pacote> getAllPacotes() {
        return findAll();
    }

    public List<Pacote> findRecent(int limit) {
        if (limit <= 0) {
            return findAll();
        }
        List<Pacote> pacotes = new ArrayList<>();
        String sql = "SELECT idPacote, descricao, nome, preco_base, numero_pessoas_adultas, numero_criancas, idReserva "
                   + "FROM PACOTE ORDER BY idPacote DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    pacotes.add(map(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return pacotes;
    }

    public List<Pacote> findAll() {
        List<Pacote> pacotes = new ArrayList<>();
        String sql = "SELECT idPacote, descricao, nome, preco_base, numero_pessoas_adultas, numero_criancas, idReserva "
                   + "FROM PACOTE ORDER BY idPacote DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                pacotes.add(map(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return pacotes;
    }

    public Pacote findById(int id) {
        String sql = "SELECT idPacote, descricao, nome, preco_base, numero_pessoas_adultas, numero_criancas, idReserva "
                   + "FROM PACOTE WHERE idPacote = ?";

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
        String sql = "SELECT idPacote, descricao, nome, preco_base, numero_pessoas_adultas, numero_criancas, idReserva "
                   + "FROM PACOTE WHERE idReserva = ? LIMIT 1";

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
            setIdReserva(stmt, 6, pacote.getIdReserva());
            stmt.setInt(7, pacote.getIdPacote());

            int rows = stmt.executeUpdate();
            System.out.println("Pacote updated successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

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

    public boolean deleteById(int idPacote) {
        return delete(idPacote);
    }

    public boolean delete(Pacote pacote) {
        return delete(pacote.getIdPacote());
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM PACOTE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Pacote map(ResultSet rs) throws SQLException {
        int idReserva = rs.getInt("idReserva");
        if (rs.wasNull()) {
            idReserva = 0;
        }
        return new Pacote(
            rs.getInt("idPacote"),
            rs.getString("descricao"),
            rs.getString("nome"),
            rs.getFloat("preco_base"),
            rs.getInt("numero_pessoas_adultas"),
            rs.getInt("numero_criancas"),
            idReserva
        );
    }
}
