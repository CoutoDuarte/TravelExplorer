package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Pagamento;

public class PagamentoCRUD {

    // CREATE
    public boolean insert(Pagamento pagamento) {
        String sql = "INSERT INTO PAGAMENTO (idPagamento, valor, metodo, data_pagamento, idCliente, idReserva) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, pagamento.getIdPagamento());
            stmt.setFloat(2, pagamento.getValor());
            stmt.setString(3, pagamento.getMetodo());

            if (pagamento.getDataPagamento() != null) {
                stmt.setDate(4, pagamento.getDataPagamento());
            } else {
                stmt.setNull(4, Types.DATE);
            }

            stmt.setInt(5, pagamento.getIdCliente());
            stmt.setInt(6, pagamento.getIdReserva());

            int rows = stmt.executeUpdate();
            System.out.println("Pagamento inserted successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - todos
    public List<Pagamento> getAllPagamentos() {
        List<Pagamento> pagamentos = new ArrayList<>();
        String sql = "SELECT * FROM PAGAMENTO";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                pagamentos.add(map(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return pagamentos;
    }

    public List<Pagamento> findAll() {
        return getAllPagamentos();
    }

    // READ - por ID
    public Pagamento findById(int id) {
        String sql = "SELECT * FROM PAGAMENTO WHERE idPagamento = ?";

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

    // READ - por cliente
    public List<Pagamento> findByCliente(int idCliente) {
        List<Pagamento> pagamentos = new ArrayList<>();
        String sql = "SELECT * FROM PAGAMENTO WHERE idCliente = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCliente);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    pagamentos.add(map(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return pagamentos;
    }

    // READ - por reserva
    public List<Pagamento> findByReserva(int idReserva) {
        List<Pagamento> pagamentos = new ArrayList<>();
        String sql = "SELECT * FROM PAGAMENTO WHERE idReserva = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idReserva);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    pagamentos.add(map(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return pagamentos;
    }

    // UPDATE
    public boolean update(Pagamento pagamento) {
        String sql = "UPDATE PAGAMENTO SET valor = ?, metodo = ?, data_pagamento = ?, "
                   + "idCliente = ?, idReserva = ? WHERE idPagamento = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setFloat(1, pagamento.getValor());
            stmt.setString(2, pagamento.getMetodo());

            if (pagamento.getDataPagamento() != null) {
                stmt.setDate(3, pagamento.getDataPagamento());
            } else {
                stmt.setNull(3, Types.DATE);
            }

            stmt.setInt(4, pagamento.getIdCliente());
            stmt.setInt(5, pagamento.getIdReserva());
            stmt.setInt(6, pagamento.getIdPagamento());

            int rows = stmt.executeUpdate();
            System.out.println("Pagamento updated successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE - por ID
    public boolean delete(int id) {
        String sql = "DELETE FROM PAGAMENTO WHERE idPagamento = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            int rows = stmt.executeUpdate();
            System.out.println("Pagamento deleted!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Pagamento pagamento) {
        return delete(pagamento.getIdPagamento());
    }

    // Mapper privado
    private Pagamento map(ResultSet rs) throws SQLException {
        return new Pagamento(
            rs.getInt("idPagamento"),
            rs.getFloat("valor"),
            rs.getString("metodo"),
            rs.getDate("data_pagamento"),
            rs.getInt("idCliente"),
            rs.getInt("idReserva")
        );
    }
}