package Connection.CRUD;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.ClienteOfertaGuardada;

public class ClienteOfertaGuardadaCRUD {

    public static List<ClienteOfertaGuardada> findSavedOffersByCliente(int idCliente) throws SQLException {
        return listarPorCliente(idCliente);
    }

    public static List<ClienteOfertaGuardada> listarPorCliente(int idCliente) throws SQLException {
        List<ClienteOfertaGuardada> ofertas = new ArrayList<>();
        String sql = "SELECT p.idPacote, p.nome, p.descricao, p.preco_base, p.numero_pessoas_adultas, p.numero_criancas, cog.data_guardado, MIN(v.destino) AS destino, MIN(v.origem) AS origem, MIN(v.data_hora_partida) AS data_partida, MIN(v.data_hora_regresso) AS data_regresso, MIN(a.nome) AS alojamento_nome, MIN(a.tipo_estadia) AS tipo_estadia FROM CLIENTE_OFERTA_GUARDADA cog JOIN PACOTE p ON p.idPacote = cog.idPacote LEFT JOIN PACOTE_VIAGENS pv ON pv.idPacote = p.idPacote LEFT JOIN VIAGENS v ON v.idViagem = pv.idViagem LEFT JOIN PACOTE_ALOJAMENTO pa ON pa.idPacote = p.idPacote LEFT JOIN ALOJAMENTO a ON a.idAlojamento = pa.idAlojamento WHERE cog.idCliente = ? GROUP BY p.idPacote, p.nome, p.descricao, p.preco_base, p.numero_pessoas_adultas, p.numero_criancas, cog.data_guardado ORDER BY cog.data_guardado DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idCliente);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ofertas.add(map(idCliente, rs));
                }
            }
        }

        return ofertas;
    }

    public static boolean isGuardada(int idCliente, int idPacote) {
        String sql = "SELECT 1 FROM CLIENTE_OFERTA_GUARDADA WHERE idCliente = ? AND idPacote = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idCliente);
            stmt.setInt(2, idPacote);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }

    public static boolean guardarOferta(int idCliente, int idPacote) throws SQLException {
        String sql = "INSERT INTO CLIENTE_OFERTA_GUARDADA (idCliente, idPacote) VALUES (?, ?) ON DUPLICATE KEY UPDATE data_guardado = CURRENT_TIMESTAMP";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idCliente);
            stmt.setInt(2, idPacote);
            return stmt.executeUpdate() > 0;
        }
    }

    public static boolean removerOferta(int idCliente, int idPacote) throws SQLException {
        String sql = "DELETE FROM CLIENTE_OFERTA_GUARDADA WHERE idCliente = ? AND idPacote = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idCliente);
            stmt.setInt(2, idPacote);
            return stmt.executeUpdate() > 0;
        }
    }

    public static boolean existeOfertaGuardada(int idCliente, int idPacote) throws SQLException {
        String sql = "SELECT 1 FROM CLIENTE_OFERTA_GUARDADA WHERE idCliente = ? AND idPacote = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idCliente);
            stmt.setInt(2, idPacote);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    public static int contarPorCliente(int idCliente) throws SQLException {
        String sql = "SELECT COUNT(*) FROM CLIENTE_OFERTA_GUARDADA WHERE idCliente = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idCliente);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    private static ClienteOfertaGuardada map(int idCliente, ResultSet rs) throws SQLException {
        return new ClienteOfertaGuardada(
            idCliente,
            rs.getInt("idPacote"),
            timestampToString(rs.getTimestamp("data_guardado")),
            rs.getString("nome"),
            rs.getString("descricao"),
            rs.getDouble("preco_base"),
            rs.getInt("numero_pessoas_adultas"),
            rs.getInt("numero_criancas"),
            rs.getString("destino"),
            rs.getString("origem"),
            timestampToString(rs.getTimestamp("data_partida")),
            timestampToString(rs.getTimestamp("data_regresso")),
            rs.getString("alojamento_nome"),
            rs.getString("tipo_estadia")
        );
    }

    private static String timestampToString(Timestamp timestamp) {
        if (timestamp == null) {
            return "";
        }
        return timestamp.toLocalDateTime().toString();
    }
}
