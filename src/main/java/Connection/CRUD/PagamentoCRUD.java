package Connection.CRUD;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Pagamento;

public class PagamentoCRUD {

    public void insert(Pagamento p) {
        String sql = "INSERT INTO PAGAMENTO (idPagamento, valor, metodo, data_pagamento, idCliente, idReserva) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, p.getIdPagamento());
            stmt.setFloat(2, p.getValor());
            stmt.setString(3, p.getMetodo());
            stmt.setDate(4, p.getDataPagamento());
            stmt.setInt(5, p.getIdCliente());
            stmt.setInt(6, p.getIdReserva());

            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Pagamento> getAll() {
        List<Pagamento> lista = new ArrayList<>();
        String sql = "SELECT * FROM PAGAMENTO";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                lista.add(new Pagamento(
                    rs.getInt("idPagamento"),
                    rs.getFloat("valor"),
                    rs.getString("metodo"),
                    rs.getDate("data_pagamento"),
                    rs.getInt("idCliente"),
                    rs.getInt("idReserva")
                ));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

    public void update(Pagamento p) {
        String sql = "UPDATE PAGAMENTO SET valor=?, metodo=?, data_pagamento=?, idCliente=?, idReserva=? WHERE idPagamento=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setFloat(1, p.getValor());
            stmt.setString(2, p.getMetodo());
            stmt.setDate(3, p.getDataPagamento());
            stmt.setInt(4, p.getIdCliente());
            stmt.setInt(5, p.getIdReserva());
            stmt.setInt(6, p.getIdPagamento());

            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM PAGAMENTO WHERE idPagamento=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}