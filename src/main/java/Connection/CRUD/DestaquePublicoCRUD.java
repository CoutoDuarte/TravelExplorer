package Connection.CRUD;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.DestaquePublico;

public class DestaquePublicoCRUD {

    public List<DestaquePublico> findActiveOrdered() throws SQLException {
        String sql = "SELECT idDestaque, titulo, subtitulo, tipo, destino, ordem, ativo, idPacote "
                + "FROM DESTAQUE_PUBLICO WHERE ativo = 1 ORDER BY ordem ASC, idDestaque ASC";
        return queryList(sql, 0);
    }

    public List<DestaquePublico> findActiveOrdered(int limit) throws SQLException {
        if (limit <= 0) {
            return findActiveOrdered();
        }
        String sql = "SELECT idDestaque, titulo, subtitulo, tipo, destino, ordem, ativo, idPacote "
                + "FROM DESTAQUE_PUBLICO WHERE ativo = 1 ORDER BY ordem ASC, idDestaque ASC LIMIT ?";
        return queryList(sql, limit);
    }

    private List<DestaquePublico> queryList(String sql, int limit) throws SQLException {
        List<DestaquePublico> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (limit > 0) {
                stmt.setInt(1, limit);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    private DestaquePublico map(ResultSet rs) throws SQLException {
        DestaquePublico d = new DestaquePublico();
        d.setIdDestaque(rs.getInt("idDestaque"));
        d.setTitulo(rs.getString("titulo"));
        d.setSubtitulo(rs.getString("subtitulo"));
        d.setTipo(rs.getString("tipo"));
        d.setDestino(rs.getString("destino"));
        d.setOrdem(rs.getInt("ordem"));
        d.setAtivo(rs.getInt("ativo") == 1);
        int idPacote = rs.getInt("idPacote");
        if (rs.wasNull()) {
            d.setIdPacote(null);
        } else {
            d.setIdPacote(idPacote);
        }
        return d;
    }
}
