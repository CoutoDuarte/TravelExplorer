package Connection.CRUD;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Transporte;

public class TransporteCRUD {

    public void insert(Transporte t) {
        String sql = "INSERT INTO TRANSPORTE (idTransporte, empresa, tipo, origem, destino, data_hora_partida, data_hora_chegada, preco, lugares) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, t.getIdTransporte());
            stmt.setString(2, t.getEmpresa());
            stmt.setString(3, t.getTipo());
            stmt.setString(4, t.getOrigem());
            stmt.setString(5, t.getDestino());
            stmt.setTimestamp(6, t.getDataHoraPartida());
            stmt.setTimestamp(7, t.getDataHoraChegada());
            stmt.setFloat(8, t.getPreco());
            stmt.setInt(9, t.getLugares());

            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Transporte> getAll() {
        List<Transporte> lista = new ArrayList<>();
        String sql = "SELECT * FROM TRANSPORTE";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                lista.add(new Transporte(
                    rs.getInt("idTransporte"),
                    rs.getString("empresa"),
                    rs.getString("tipo"),
                    rs.getString("origem"),
                    rs.getString("destino"),
                    rs.getTimestamp("data_hora_partida"),
                    rs.getTimestamp("data_hora_chegada"),
                    rs.getFloat("preco"),
                    rs.getInt("lugares")
                ));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

    public List<Transporte> findByPacote(int idPacote) {
        List<Transporte> lista = new ArrayList<>();
        String sql = "SELECT t.* FROM TRANSPORTE t JOIN PACOTE_TRANSPORTE pt ON pt.idTransporte = t.idTransporte WHERE pt.idPacote = ? ORDER BY t.data_hora_partida ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPacote);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    lista.add(new Transporte(
                        rs.getInt("idTransporte"),
                        rs.getString("empresa"),
                        rs.getString("tipo"),
                        rs.getString("origem"),
                        rs.getString("destino"),
                        rs.getTimestamp("data_hora_partida"),
                        rs.getTimestamp("data_hora_chegada"),
                        rs.getFloat("preco"),
                        rs.getInt("lugares")
                    ));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

    public void update(Transporte t) {
        String sql = "UPDATE TRANSPORTE SET empresa=?, tipo=?, origem=?, destino=?, data_hora_partida=?, data_hora_chegada=?, preco=?, lugares=? WHERE idTransporte=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, t.getEmpresa());
            stmt.setString(2, t.getTipo());
            stmt.setString(3, t.getOrigem());
            stmt.setString(4, t.getDestino());
            stmt.setTimestamp(5, t.getDataHoraPartida());
            stmt.setTimestamp(6, t.getDataHoraChegada());
            stmt.setFloat(7, t.getPreco());
            stmt.setInt(8, t.getLugares());
            stmt.setInt(9, t.getIdTransporte());

            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM TRANSPORTE WHERE idTransporte=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}