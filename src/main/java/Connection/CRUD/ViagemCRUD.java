package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Viagens;

public class ViagemCRUD {

    // CREATE
    public boolean insert(Viagens viagem) {
        String sql = "INSERT INTO VIAGENS (idViagem, numero_bilhetes_adulto, numero_bilhetes_crianca, "
                   + "preco, origem, destino, data_hora_partida, data_hora_regresso, descricao, empresa) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, viagem.getIdViagem());
            stmt.setInt(2, viagem.getNumBilhetesAdulto());
            stmt.setInt(3, viagem.getNumBilhetesCrianca());
            stmt.setFloat(4, viagem.getPreco());
            stmt.setString(5, viagem.getOrigem());
            stmt.setString(6, viagem.getDestino());

            if (viagem.getDataHoraPartida() != null) {
                stmt.setTimestamp(7, viagem.getDataHoraPartida());
            } else {
                stmt.setNull(7, Types.TIMESTAMP);
            }

            if (viagem.getDataHoraRegresso() != null) {
                stmt.setTimestamp(8, viagem.getDataHoraRegresso());
            } else {
                stmt.setNull(8, Types.TIMESTAMP);
            }

            stmt.setString(9, viagem.getDescricao());
            stmt.setString(10, viagem.getEmpresa());

            int rows = stmt.executeUpdate();
            System.out.println("Viagem inserted successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - todos
    public List<Viagens> getAll() {
        List<Viagens> lista = new ArrayList<>();
        String sql = "SELECT * FROM VIAGENS";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                lista.add(map(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    // Alias para o servlet
    public List<Viagens> findAll() {
        return getAll();
    }

    // READ - por ID
    public Viagens findById(int id) {
        String sql = "SELECT * FROM VIAGENS WHERE idViagem = ?";

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

    // UPDATE
    public boolean update(Viagens viagem) {
        String sql = "UPDATE VIAGENS SET numero_bilhetes_adulto = ?, numero_bilhetes_crianca = ?, "
                   + "preco = ?, origem = ?, destino = ?, data_hora_partida = ?, data_hora_regresso = ?, "
                   + "descricao = ?, empresa = ? WHERE idViagem = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, viagem.getNumBilhetesAdulto());
            stmt.setInt(2, viagem.getNumBilhetesCrianca());
            stmt.setFloat(3, viagem.getPreco());
            stmt.setString(4, viagem.getOrigem());
            stmt.setString(5, viagem.getDestino());

            if (viagem.getDataHoraPartida() != null) {
                stmt.setTimestamp(6, viagem.getDataHoraPartida());
            } else {
                stmt.setNull(6, Types.TIMESTAMP);
            }

            if (viagem.getDataHoraRegresso() != null) {
                stmt.setTimestamp(7, viagem.getDataHoraRegresso());
            } else {
                stmt.setNull(7, Types.TIMESTAMP);
            }

            stmt.setString(8, viagem.getDescricao());
            stmt.setString(9, viagem.getEmpresa());
            stmt.setInt(10, viagem.getIdViagem());

            int rows = stmt.executeUpdate();
            System.out.println("Viagem updated successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE - por ID
    public boolean delete(int id) {
        String sql = "DELETE FROM VIAGENS WHERE idViagem = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            int rows = stmt.executeUpdate();
            System.out.println("Viagem deleted!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE - por objeto (conveniência)
    public boolean delete(Viagens viagem) {
        return delete(viagem.getIdViagem());
    }

    // ============================
    // Mapper privado
    // ============================
    private Viagens map(ResultSet rs) throws SQLException {
        return new Viagens(
            rs.getInt("idViagem"),
            rs.getInt("numero_bilhetes_adulto"),
            rs.getInt("numero_bilhetes_crianca"),
            rs.getFloat("preco"),
            rs.getString("origem"),
            rs.getString("destino"),
            rs.getTimestamp("data_hora_partida"),
            rs.getTimestamp("data_hora_regresso"),
            rs.getString("descricao"),
            rs.getString("empresa")
        );
    }
}