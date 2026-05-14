package Connection.CRUD;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Permissao;

public class PermissaoCRUD {

    public void insert(Permissao p) {
        String sql = "INSERT INTO PERMISSAO (idPermissao, nome, descricao) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, p.getIdPermissao());
            stmt.setString(2, p.getNome());
            stmt.setString(3, p.getDescricao());

            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Permissao> getAll() {
        List<Permissao> lista = new ArrayList<>();
        String sql = "SELECT * FROM PERMISSAO";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                lista.add(new Permissao(
                    rs.getInt("idPermissao"),
                    rs.getString("nome"),
                    rs.getString("descricao")
                ));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

    public void update(Permissao p) {
        String sql = "UPDATE PERMISSAO SET nome=?, descricao=? WHERE idPermissao=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, p.getNome());
            stmt.setString(2, p.getDescricao());
            stmt.setInt(3, p.getIdPermissao());

            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM PERMISSAO WHERE idPermissao=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Permissao> findByFuncionarioId(int idFuncionario) {
        List<Permissao> lista = new ArrayList<>();
        String sql = "SELECT DISTINCT p.idPermissao, p.nome, p.descricao FROM PERMISSAO p JOIN FUNCAO_PERMISSAO fp ON fp.idPermissao = p.idPermissao JOIN FUNCIONARIO_FUNCAO ff ON ff.idFuncao = fp.idFuncao WHERE ff.idFuncionario = ? ORDER BY p.nome ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idFuncionario);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    lista.add(new Permissao(
                        rs.getInt("idPermissao"),
                        rs.getString("nome"),
                        rs.getString("descricao")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    public boolean funcionarioHasPermission(int idFuncionario, String permissionName) {
        String sql = "SELECT COUNT(*) FROM PERMISSAO p JOIN FUNCAO_PERMISSAO fp ON fp.idPermissao = p.idPermissao JOIN FUNCIONARIO_FUNCAO ff ON ff.idFuncao = fp.idFuncao WHERE ff.idFuncionario = ? AND p.nome = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idFuncionario);
            stmt.setString(2, permissionName);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}