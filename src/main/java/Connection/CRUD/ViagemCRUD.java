package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Viagens;

public class ViagemCRUD {

    // CREATE
    public void insert(Viagens viagem) {
        String sql = "INSERT INTO VIAGENS VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, viagem.getIdViagem());
            stmt.setInt(2, viagem.getNumBilhetesAdulto());
            stmt.setInt(3, viagem.getNumBilhetesCrianca());
            stmt.setFloat(4, viagem.getPreco());
            stmt.setString(5, viagem.getOrigem());
            stmt.setString(6, viagem.getDestino());
            stmt.setTimestamp(7, viagem.getDataHoraPartida());
            stmt.setTimestamp(8, viagem.getDataHoraRegresso());
            stmt.setString(9, viagem.getDescricao());
            stmt.setString(10, viagem.getEmpresa());

            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // READ
    public List<Viagens> getAll() {
        List<Viagens> lista = new ArrayList<>();
        String sql = "SELECT * FROM VIAGENS";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Viagens v = new Viagens(
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

                lista.add(v);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

    // UPDATE
    public void update(Viagens viagem) {
        String sql = "UPDATE VIAGENS SET numero_bilhetes_adulto=?, numero_bilhetes_crianca=?, preco=?, origem=?, destino=?, data_hora_partida=?, data_hora_regresso=?, descricao=?, empresa=? WHERE idViagem=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, viagem.getNumBilhetesAdulto());
            stmt.setInt(2, viagem.getNumBilhetesCrianca());
            stmt.setFloat(3, viagem.getPreco());
            stmt.setString(4, viagem.getOrigem());
            stmt.setString(5, viagem.getDestino());
            stmt.setTimestamp(6, viagem.getDataHoraPartida());
            stmt.setTimestamp(7, viagem.getDataHoraRegresso());
            stmt.setString(8, viagem.getDescricao());
            stmt.setString(9, viagem.getEmpresa());
            stmt.setInt(10, viagem.getIdViagem());

            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // DELETE
    public void delete(int id) {
        String sql = "DELETE FROM VIAGENS WHERE idViagem=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}