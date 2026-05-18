package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Reserva;

public class ReservaCRUD {

    // CREATE
    public boolean insert(Reserva reserva) {
        String sql = "INSERT INTO RESERVA (idReserva, data_reserva, total_pagar, estado, idCliente, idPacote) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, reserva.getIdReserva());

            if (reserva.getDataReserva() != null) {
            	stmt.setDate(2, java.sql.Date.valueOf(reserva.getDataReserva()));
            } else {
                stmt.setNull(2, Types.DATE);
            }

            stmt.setFloat(3, reserva.getTotalPagar());
            stmt.setString(4, reserva.getEstado());
            stmt.setInt(5, reserva.getIdCliente());
            stmt.setInt(6, reserva.getIdPacote());

            int rows = stmt.executeUpdate();
            System.out.println("Reserva inserted successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - todos
    public List<Reserva> getAllReservas() {
        List<Reserva> reservas = new ArrayList<>();
        String sql = "SELECT * FROM RESERVA ORDER BY data_reserva DESC, idReserva DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                reservas.add(map(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return reservas;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM RESERVA";
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

    public int countAtivas() {
        String sql = "SELECT COUNT(*) FROM RESERVA WHERE LOWER(estado) NOT IN ('cancelada', 'cancelado', 'concluída', 'concluida', 'finalizada', 'finalizado')";
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

    public List<Reserva> findLatest(int limite) {
        List<Reserva> reservas = new ArrayList<>();
        String sql = "SELECT * FROM RESERVA ORDER BY data_reserva DESC, idReserva DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limite);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reservas.add(map(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservas;
    }

    public List<Reserva> findAll() {
        return getAllReservas();
    }

    // READ - por ID
    public Reserva findById(int id) {
        String sql = "SELECT * FROM RESERVA WHERE idReserva = ?";

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
    public List<Reserva> findByCliente(int idCliente) {
        List<Reserva> reservas = new ArrayList<>();
        String sql = "SELECT * FROM RESERVA WHERE idCliente = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCliente);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reservas.add(map(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return reservas;
    }

    public int countByCliente(int idCliente) {
        String sql = "SELECT COUNT(*) FROM RESERVA WHERE idCliente = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCliente);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int countAtivasByCliente(int idCliente) {
        String sql = "SELECT COUNT(*) FROM RESERVA WHERE idCliente = ? AND LOWER(estado) NOT IN ('cancelada', 'cancelado', 'concluída', 'concluida', 'finalizada', 'finalizado')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCliente);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<Reserva> findLatestByCliente(int idCliente, int limite) {
        List<Reserva> reservas = new ArrayList<>();
        String sql = "SELECT * FROM RESERVA WHERE idCliente = ? ORDER BY data_reserva DESC, idReserva DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCliente);
            stmt.setInt(2, limite);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reservas.add(map(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return reservas;
    }

    public Reserva findByIdAndCliente(int idReserva, int idCliente) {
        String sql = "SELECT * FROM RESERVA WHERE idReserva = ? AND idCliente = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idReserva);
            stmt.setInt(2, idCliente);
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
    public boolean update(Reserva reserva) {
        String sql = "UPDATE RESERVA SET data_reserva = ?, total_pagar = ?, estado = ?, "
                   + "idCliente = ?, idPacote = ? WHERE idReserva = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            if (reserva.getDataReserva() != null) {
            	stmt.setDate(2, java.sql.Date.valueOf(reserva.getDataReserva()));
            } else {
                stmt.setNull(1, Types.DATE);
            }

            stmt.setFloat(2, reserva.getTotalPagar());
            stmt.setString(3, reserva.getEstado());
            stmt.setInt(4, reserva.getIdCliente());
            stmt.setInt(5, reserva.getIdPacote());
            stmt.setInt(6, reserva.getIdReserva());

            int rows = stmt.executeUpdate();
            System.out.println("Reserva updated successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE - por ID
    public boolean delete(int id) {
        String sql = "DELETE FROM RESERVA WHERE idReserva = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            int rows = stmt.executeUpdate();
            System.out.println("Reserva deleted!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Reserva reserva) {
        return delete(reserva.getIdReserva());
    }

    // Mapper privado
    public boolean updateEstado(int idReserva, int idCliente, String estado) {
        String sql = "UPDATE RESERVA SET estado = ? WHERE idReserva = ? AND idCliente = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, estado);
            stmt.setInt(2, idReserva);
            stmt.setInt(3, idCliente);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Reserva map(ResultSet rs) throws SQLException {
        Date d = rs.getDate("data_reserva");
        Reserva r = new Reserva(
            rs.getInt("idReserva"),
            d != null ? d.toLocalDate() : null,
            rs.getFloat("total_pagar"),
            rs.getString("estado"),
            rs.getInt("idCliente"),
            rs.getInt("idPacote")
        );
        try {
            r.setOrigem(rs.getString("origem"));
            r.setDestino(rs.getString("destino"));
            Date dp = rs.getDate("data_partida");
            r.setDataPartida(dp != null ? dp.toLocalDate() : null);
            Date dr = rs.getDate("data_regresso");
            r.setDataRegresso(dr != null ? dr.toLocalDate() : null);
            r.setAdultos(rs.getInt("adultos"));
            r.setCriancas(rs.getInt("criancas"));
            r.setTitulo(rs.getString("titulo"));
        } catch (SQLException ignored) {
        }
        return r;
    }
}