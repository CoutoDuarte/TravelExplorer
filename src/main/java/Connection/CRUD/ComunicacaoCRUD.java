package Connection.CRUD;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Comunicacao;

public class ComunicacaoCRUD {

    private void setIdCliente(PreparedStatement stmt, int index, int idCliente) throws SQLException {
        if (idCliente <= 0) {
            stmt.setNull(index, Types.INTEGER);
        } else {
            stmt.setInt(index, idCliente);
        }
    }

    private void setDate(PreparedStatement stmt, int index, LocalDate d) throws SQLException {
        if (d == null) {
            stmt.setNull(index, Types.DATE);
        } else {
            stmt.setDate(index, Date.valueOf(d));
        }
    }

    public List<Comunicacao> findSupportTickets() {
        List<Comunicacao> list = new ArrayList<>();
        String sql = "SELECT idComunicacao, titulo, canal, segmento, data_comunicacao, estado, mensagem, idCliente, idReserva, resposta, data_resposta, idFuncionarioResposta FROM COMUNICACAO WHERE canal = 'Área de Cliente' ORDER BY idComunicacao DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapExtended(rs));
            }
        } catch (SQLException e) {
            return findAll();
        }
        return list;
    }

    public Comunicacao findByReserva(int idReserva) {
        String sql = "SELECT idComunicacao, titulo, canal, segmento, data_comunicacao, estado, mensagem, idCliente, idReserva, resposta, data_resposta, idFuncionarioResposta FROM COMUNICACAO WHERE idReserva = ? ORDER BY idComunicacao DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idReserva);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapExtended(rs);
                }
            }
        } catch (SQLException e) {
            return null;
        }
        return null;
    }

    public boolean createSupport(Comunicacao c) {
        int id = getNextId();
        String sql = "INSERT INTO COMUNICACAO (idComunicacao, titulo, canal, segmento, data_comunicacao, estado, mensagem, idCliente, idReserva) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.setString(2, c.getTitulo());
            stmt.setString(3, c.getCanal());
            stmt.setString(4, c.getSegmento());
            setDate(stmt, 5, c.getDataComunicacao());
            stmt.setString(6, c.getEstado());
            stmt.setString(7, c.getMensagem());
            setIdCliente(stmt, 8, c.getIdCliente());
            if (c.getIdReserva() > 0) {
                stmt.setInt(9, c.getIdReserva());
            } else {
                stmt.setNull(9, Types.INTEGER);
            }
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            return create(c);
        }
    }

    public boolean answerSupport(int idComunicacao, String resposta, int idFuncionario) {
        String sql = "UPDATE COMUNICACAO SET resposta = ?, data_resposta = ?, idFuncionarioResposta = ?, estado = ? WHERE idComunicacao = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, resposta);
            stmt.setTimestamp(2, java.sql.Timestamp.valueOf(LocalDateTime.now()));
            stmt.setInt(3, idFuncionario);
            stmt.setString(4, "Respondido");
            stmt.setInt(5, idComunicacao);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Comunicacao map(ResultSet rs) throws SQLException {
        return mapExtended(rs);
    }

    private Comunicacao mapExtended(ResultSet rs) throws SQLException {
        Date dc = rs.getDate("data_comunicacao");
        int idC = rs.getInt("idCliente");
        if (rs.wasNull()) {
            idC = 0;
        }
        int idReserva = 0;
        String resposta = null;
        LocalDateTime dataResposta = null;
        int idFunc = 0;
        try {
            idReserva = rs.getInt("idReserva");
            if (rs.wasNull()) {
                idReserva = 0;
            }
            resposta = rs.getString("resposta");
            java.sql.Timestamp tr = rs.getTimestamp("data_resposta");
            dataResposta = tr != null ? tr.toLocalDateTime() : null;
            idFunc = rs.getInt("idFuncionarioResposta");
            if (rs.wasNull()) {
                idFunc = 0;
            }
        } catch (SQLException ignored) {
        }
        return new Comunicacao(
            rs.getInt("idComunicacao"),
            rs.getString("titulo"),
            rs.getString("canal"),
            rs.getString("segmento"),
            dc != null ? dc.toLocalDate() : null,
            rs.getString("estado"),
            rs.getString("mensagem"),
            idC,
            idReserva,
            resposta,
            dataResposta,
            idFunc
        );
    }

    public List<Comunicacao> findAll() {
        List<Comunicacao> list = new ArrayList<>();
        String sql = "SELECT idComunicacao, titulo, canal, segmento, data_comunicacao, estado, mensagem, idCliente FROM COMUNICACAO ORDER BY idComunicacao DESC";
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

    public Comunicacao findById(int idComunicacao) {
        String sql = "SELECT idComunicacao, titulo, canal, segmento, data_comunicacao, estado, mensagem, idCliente FROM COMUNICACAO WHERE idComunicacao = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idComunicacao);
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
        String sql = "SELECT COALESCE(MAX(idComunicacao), 0) + 1 FROM COMUNICACAO";
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

    public int countPendentes() {
        String sql = "SELECT COUNT(*) FROM COMUNICACAO WHERE LOWER(estado) IN ('pendente', 'planeada', 'rascunho', 'em preparação', 'em preparacao')";
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

    public boolean create(Comunicacao c) {
        int id = getNextId();
        String sql = "INSERT INTO COMUNICACAO (idComunicacao, titulo, canal, segmento, data_comunicacao, estado, mensagem, idCliente) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.setString(2, c.getTitulo());
            stmt.setString(3, c.getCanal());
            stmt.setString(4, c.getSegmento());
            setDate(stmt, 5, c.getDataComunicacao());
            stmt.setString(6, c.getEstado());
            stmt.setString(7, c.getMensagem());
            setIdCliente(stmt, 8, c.getIdCliente());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean update(Comunicacao c) {
        String sql = "UPDATE COMUNICACAO SET titulo = ?, canal = ?, segmento = ?, data_comunicacao = ?, estado = ?, mensagem = ?, idCliente = ? WHERE idComunicacao = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, c.getTitulo());
            stmt.setString(2, c.getCanal());
            stmt.setString(3, c.getSegmento());
            setDate(stmt, 4, c.getDataComunicacao());
            stmt.setString(5, c.getEstado());
            stmt.setString(6, c.getMensagem());
            setIdCliente(stmt, 7, c.getIdCliente());
            stmt.setInt(8, c.getIdComunicacao());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteById(int idComunicacao) {
        String sql = "DELETE FROM COMUNICACAO WHERE idComunicacao = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idComunicacao);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
