package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import org.mindrot.jbcrypt.BCrypt;

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

    public boolean createStaffWithRole(Funcionario funcionario, String plainPassword, int idFuncao) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            return false;
        }
        if (findByEmail(funcionario.getEmail()) != null) {
            return false;
        }
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            int nextId;
            try (PreparedStatement st = conn.prepareStatement("SELECT COALESCE(MAX(idFuncionario), 0) + 1 FROM FUNCIONARIO");
                 ResultSet rs = st.executeQuery()) {
                if (!rs.next()) {
                    conn.rollback();
                    return false;
                }
                nextId = rs.getInt(1);
            }
            String hash = BCrypt.hashpw(plainPassword, BCrypt.gensalt());
            String sql = "INSERT INTO FUNCIONARIO (idFuncionario, nome, email, telefone, salario, password_hash) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ins = conn.prepareStatement(sql)) {
                ins.setInt(1, nextId);
                ins.setString(2, funcionario.getNome());
                ins.setString(3, funcionario.getEmail());
                ins.setInt(4, funcionario.getTelemovel());
                ins.setFloat(5, funcionario.getSalario());
                ins.setString(6, hash);
                ins.executeUpdate();
            }
            try (PreparedStatement insFf = conn.prepareStatement("INSERT INTO FUNCIONARIO_FUNCAO (idFuncionario, idFuncao) VALUES (?, ?)")) {
                insFf.setInt(1, nextId);
                insFf.setInt(2, idFuncao);
                insFf.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
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