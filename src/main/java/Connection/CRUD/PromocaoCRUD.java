package Connection.CRUD;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Promocao;

public class PromocaoCRUD {

    private void setIdPacote(PreparedStatement stmt, int index, int idPacote) throws SQLException {
        if (idPacote <= 0) {
            stmt.setNull(index, Types.INTEGER);
        } else {
            stmt.setInt(index, idPacote);
        }
    }

    private void setDate(PreparedStatement stmt, int index, LocalDate d) throws SQLException {
        if (d == null) {
            stmt.setNull(index, Types.DATE);
        } else {
            stmt.setDate(index, Date.valueOf(d));
        }
    }

    private Promocao map(ResultSet rs) throws SQLException {
        Date pi = rs.getDate("periodo_inicio");
        Date pf = rs.getDate("periodo_fim");
        int idP = rs.getInt("idPacote");
        if (rs.wasNull()) {
            idP = 0;
        }
        return new Promocao(
            rs.getInt("idPromocao"),
            rs.getString("titulo"),
            rs.getString("destino"),
            pi != null ? pi.toLocalDate() : null,
            pf != null ? pf.toLocalDate() : null,
            rs.getString("condicao"),
            rs.getString("estado"),
            idP
        );
    }

    public List<Promocao> findActive() {
        List<Promocao> list = new ArrayList<>();
        String sql = "SELECT idPromocao, titulo, destino, periodo_inicio, periodo_fim, condicao, estado, idPacote "
                + "FROM PROMOCAO WHERE LOWER(estado) IN ('ativa', 'activo', 'ativo', 'active', 'publicada') "
                + "ORDER BY idPromocao DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Promocao> findAll() {
        List<Promocao> list = new ArrayList<>();
        String sql = "SELECT idPromocao, titulo, destino, periodo_inicio, periodo_fim, condicao, estado, idPacote FROM PROMOCAO ORDER BY idPromocao DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Promocao findById(int idPromocao) {
        String sql = "SELECT idPromocao, titulo, destino, periodo_inicio, periodo_fim, condicao, estado, idPacote FROM PROMOCAO WHERE idPromocao = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPromocao);
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

    public int getNextId() {
        String sql = "SELECT COALESCE(MAX(idPromocao), 0) + 1 FROM PROMOCAO";
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

    public int countAtivas() {
        String sql = "SELECT COUNT(*) FROM PROMOCAO WHERE LOWER(estado) IN ('ativa', 'activo', 'ativo', 'publicada')";
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

    public boolean create(Promocao p) {
        int id = getNextId();
        String sql = "INSERT INTO PROMOCAO (idPromocao, titulo, destino, periodo_inicio, periodo_fim, condicao, estado, idPacote) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.setString(2, p.getTitulo());
            stmt.setString(3, p.getDestino());
            setDate(stmt, 4, p.getPeriodoInicio());
            setDate(stmt, 5, p.getPeriodoFim());
            stmt.setString(6, p.getCondicao());
            stmt.setString(7, p.getEstado());
            setIdPacote(stmt, 8, p.getIdPacote());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean update(Promocao p) {
        String sql = "UPDATE PROMOCAO SET titulo = ?, destino = ?, periodo_inicio = ?, periodo_fim = ?, condicao = ?, estado = ?, idPacote = ? WHERE idPromocao = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, p.getTitulo());
            stmt.setString(2, p.getDestino());
            setDate(stmt, 3, p.getPeriodoInicio());
            setDate(stmt, 4, p.getPeriodoFim());
            stmt.setString(5, p.getCondicao());
            stmt.setString(6, p.getEstado());
            setIdPacote(stmt, 7, p.getIdPacote());
            stmt.setInt(8, p.getIdPromocao());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteById(int idPromocao) {
        String sql = "DELETE FROM PROMOCAO WHERE idPromocao = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPromocao);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
