package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Funcionario;

public class FuncionarioCRUD {

    private static final String DEFAULT_PASSWORD_HASH =
            "$2a$10$7KbPn6yW4O2qcNPhVBtfTuPMWUW/8X2yWXEuv4J4DPl0l8tBSJrw2";

    // CREATE
    public boolean insert(Funcionario funcionario) {
        String sql = "INSERT INTO FUNCIONARIO (idFuncionario, nome, email, telefone, salario, password_hash) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, funcionario.getIdFuncionario());
            stmt.setString(2, funcionario.getNome());
            stmt.setString(3, funcionario.getEmail());
            stmt.setInt(4, funcionario.getTelemovel());
            stmt.setFloat(5, funcionario.getSalario());

            String passwordHash = funcionario.getPasswordHash();
            if (passwordHash == null || passwordHash.trim().isEmpty()) {
                passwordHash = DEFAULT_PASSWORD_HASH;
            }
            stmt.setString(6, passwordHash);

            int rows = stmt.executeUpdate();
            System.out.println("Funcionario inserted successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - todos
    public List<Funcionario> getAllFuncionarios() {
        List<Funcionario> funcionarios = new ArrayList<>();
        String sql = "SELECT * FROM FUNCIONARIO";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                funcionarios.add(map(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return funcionarios;
    }

    public List<Funcionario> findAll() {
        return getAllFuncionarios();
    }

    // READ - por ID
    public Funcionario findById(int id) {
        String sql = "SELECT * FROM FUNCIONARIO WHERE idFuncionario = ?";

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

    // READ - por email (útil para login)
    public Funcionario findByEmail(String email) {
        String sql = "SELECT * FROM FUNCIONARIO WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
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
    public boolean update(Funcionario funcionario) {
        String passwordHash = funcionario.getPasswordHash();
        boolean shouldUpdatePassword = passwordHash != null && !passwordHash.trim().isEmpty();

        String sql = shouldUpdatePassword
                ? "UPDATE FUNCIONARIO SET nome = ?, email = ?, telefone = ?, salario = ?, password_hash = ? WHERE idFuncionario = ?"
                : "UPDATE FUNCIONARIO SET nome = ?, email = ?, telefone = ?, salario = ? WHERE idFuncionario = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, funcionario.getNome());
            stmt.setString(2, funcionario.getEmail());
            stmt.setInt(3, funcionario.getTelemovel());
            stmt.setFloat(4, funcionario.getSalario());

            if (shouldUpdatePassword) {
                stmt.setString(5, passwordHash);
                stmt.setInt(6, funcionario.getIdFuncionario());
            } else {
                stmt.setInt(5, funcionario.getIdFuncionario());
            }

            int rows = stmt.executeUpdate();
            System.out.println("Funcionario updated successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE - por ID
    public boolean delete(int id) {
        String sql = "DELETE FROM FUNCIONARIO WHERE idFuncionario = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            int rows = stmt.executeUpdate();
            System.out.println("Funcionario deleted!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Funcionario funcionario) {
        return delete(funcionario.getIdFuncionario());
    }

    // Mapper privado
    private Funcionario map(ResultSet rs) throws SQLException {
        return new Funcionario(
            rs.getInt("idFuncionario"),
            rs.getString("nome"),
            rs.getString("email"),
            rs.getInt("telefone"),
            rs.getFloat("salario"),
            rs.getString("password_hash")
        );
    }
}