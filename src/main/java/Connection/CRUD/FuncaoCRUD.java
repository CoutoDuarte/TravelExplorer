package Connection.CRUD;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Funcao;

public class FuncaoCRUD {

    public List<Funcao> findAll() {
        List<Funcao> list = new ArrayList<>();
        String sql = "SELECT idFuncao, nome, descricao FROM FUNCAO ORDER BY nome ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(new Funcao(rs.getInt("idFuncao"), rs.getString("nome"), rs.getString("descricao")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Funcao> findByFuncionarioId(int idFuncionario) {
        List<Funcao> list = new ArrayList<>();
        String sql = "SELECT f.idFuncao, f.nome, f.descricao FROM FUNCAO f JOIN FUNCIONARIO_FUNCAO ff ON ff.idFuncao = f.idFuncao WHERE ff.idFuncionario = ? ORDER BY f.nome ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idFuncionario);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new Funcao(rs.getInt("idFuncao"), rs.getString("nome"), rs.getString("descricao")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean assignFuncaoToFuncionario(int idFuncionario, int idFuncao) {
        String sql = "INSERT INTO FUNCIONARIO_FUNCAO (idFuncionario, idFuncao) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idFuncionario);
            stmt.setInt(2, idFuncao);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean removeFuncoesFromFuncionario(int idFuncionario) {
        String sql = "DELETE FROM FUNCIONARIO_FUNCAO WHERE idFuncionario = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idFuncionario);
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
