package Connection.CRUD;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Connection.DBConnection;
import Connection.Classes.Cliente;

public class ClienteCRUD {

    // Hash padrão (bcrypt) usado quando não é fornecida password — substituir por hash gerado em runtime em produção
    private static final String DEFAULT_PASSWORD_HASH =
            "$2a$10$7KbPn6yW4O2qcNPhVBtfTuPMWUW/8X2yWXEuv4J4DPl0l8tBSJrw2";

    // CRUD - CREATE
    public boolean insert(Cliente cliente) {
        String sql = "INSERT INTO CLIENTE (idCliente, nome, email, morada, NIF, telemovel, data_nascimento, password_hash) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cliente.getIdCliente());
            stmt.setString(2, cliente.getNome());
            stmt.setString(3, cliente.getEmail());
            stmt.setString(4, cliente.getMorada());
            stmt.setInt(5, cliente.getNIF());
            stmt.setInt(6, cliente.getTelemovel());

            if (cliente.getDataNasc() != null) {
                stmt.setDate(7, java.sql.Date.valueOf(cliente.getDataNasc()));
            } else {
                stmt.setNull(7, java.sql.Types.DATE);
            }

            String passwordHash = cliente.getPasswordHash();
            if (passwordHash == null || passwordHash.trim().isEmpty()) {
                passwordHash = DEFAULT_PASSWORD_HASH;
            }
            stmt.setString(8, passwordHash);

            int rows = stmt.executeUpdate();
            System.out.println("Cliente inserted successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // CRUD - READ (todos)
    public List<Cliente> getAllClientes() {
        List<Cliente> clientes = new ArrayList<>();
        String sql = "SELECT * FROM CLIENTE";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                clientes.add(map(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return clientes;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM CLIENTE";
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

    public int countReservasByCliente(int idCliente) {
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

    public String findLatestReservaNameByCliente(int idCliente) {
        String sql = "SELECT p.nome FROM RESERVA r JOIN PACOTE p ON p.idPacote = r.idPacote WHERE r.idCliente = ? ORDER BY r.data_reserva DESC, r.idReserva DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idCliente);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("nome");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Alias para compatibilidade com o servlet (que chama findAll())
    public List<Cliente> findAll() {
        return getAllClientes();
    }

    // CRUD - READ (por ID)
    public Cliente findById(int id) {
        String sql = "SELECT * FROM CLIENTE WHERE idCliente = ?";

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

    // Útil para login / verificações de unicidade
    public Cliente findByEmail(String email) {
        String sql = "SELECT * FROM CLIENTE WHERE email = ?";

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

    // CRUD - UPDATE
    public boolean update(Cliente cliente) {
        String passwordHash = cliente.getPasswordHash();
        boolean shouldUpdatePassword = passwordHash != null && !passwordHash.trim().isEmpty();

        String sql = shouldUpdatePassword
                ? "UPDATE CLIENTE SET nome = ?, email = ?, morada = ?, NIF = ?, telemovel = ?, data_nascimento = ?, password_hash = ? WHERE idCliente = ?"
                : "UPDATE CLIENTE SET nome = ?, email = ?, morada = ?, NIF = ?, telemovel = ?, data_nascimento = ? WHERE idCliente = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, cliente.getNome());
            stmt.setString(2, cliente.getEmail());
            stmt.setString(3, cliente.getMorada());
            stmt.setInt(4, cliente.getNIF());
            stmt.setInt(5, cliente.getTelemovel());

            if (cliente.getDataNasc() != null) {
                stmt.setDate(6, java.sql.Date.valueOf(cliente.getDataNasc()));
            } else {
                stmt.setNull(6, java.sql.Types.DATE);
            }

            if (shouldUpdatePassword) {
                stmt.setString(7, passwordHash);
                stmt.setInt(8, cliente.getIdCliente());
            } else {
                stmt.setInt(7, cliente.getIdCliente());
            }

            int rows = stmt.executeUpdate();
            System.out.println("Cliente updated successfully!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // CRUD - DELETE (por objeto)
    public boolean delete(Cliente cliente) {
        return delete(cliente.getIdCliente());
    }

    // CRUD - DELETE (por ID — usado pelo servlet)
    public boolean delete(int idCliente) {
        String sql = "DELETE FROM CLIENTE WHERE idCliente = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCliente);
            int rows = stmt.executeUpdate();
            System.out.println("Cliente deleted!");
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Mapeia ResultSet → Cliente
    private Cliente map(ResultSet rs) throws SQLException {
        Date dataNascSql = rs.getDate("data_nascimento");
        return new Cliente(
            rs.getInt("idCliente"),
            rs.getString("nome"),
            rs.getString("email"),
            rs.getString("morada"),
            rs.getInt("NIF"),
            rs.getInt("telemovel"),
            dataNascSql != null ? dataNascSql.toLocalDate() : null,
            rs.getString("password_hash")
        );
    }
}