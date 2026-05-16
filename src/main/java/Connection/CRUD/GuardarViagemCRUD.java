package Connection.CRUD;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

import Connection.DBConnection;
import Connection.Classes.CriarSugestaoRequest;
import Connection.Classes.HotelSugestao;
import Connection.Classes.SugestaoViagem;
import Connection.Classes.VooInfo;

public class GuardarViagemCRUD {

    public int guardar(int idCliente, CriarSugestaoRequest pedido, SugestaoViagem sugestao) throws SQLException {
        Connection conn = DBConnection.getConnection();
        conn.setAutoCommit(false);
        try {
            float total = computeTotal(sugestao, pedido);
            int idReserva = nextId(conn, "RESERVA", "idReserva");
            int idPacote = nextId(conn, "PACOTE", "idPacote");

            insertReserva(conn, idReserva, idCliente, total);
            insertPacote(conn, idPacote, idReserva, pedido, sugestao);
            updateReservaPacote(conn, idReserva, idPacote);

            int idViagemIda = nextId(conn, "VIAGENS", "idViagem");
            insertViagem(conn, idViagemIda, pedido, pedido.vooIdaSelecionado, pedido.dataPartida);
            linkPacoteViagem(conn, idPacote, idViagemIda);

            int idViagemRegresso = nextId(conn, "VIAGENS", "idViagem");
            insertViagem(conn, idViagemRegresso, pedido, pedido.vooRegressoSelecionado, pedido.dataRegresso);
            linkPacoteViagem(conn, idPacote, idViagemRegresso);

            if (pedido.hotelSelecionado != null && notBlank(pedido.hotelSelecionado.nome)) {
                int idAlojamento = nextId(conn, "ALOJAMENTO", "idAlojamento");
                insertAlojamento(conn, idAlojamento, pedido, pedido.hotelSelecionado);
                linkPacoteAlojamento(conn, idPacote, idAlojamento);
            }

            if (sugestao != null && notBlank(sugestao.transporteSugerido)) {
                int idTransporte = nextId(conn, "TRANSPORTE", "idTransporte");
                insertTransporte(conn, idTransporte, pedido, sugestao.transporteSugerido);
                linkPacoteTransporte(conn, idPacote, idTransporte);
            }

            int idPagamento = nextId(conn, "PAGAMENTO", "idPagamento");
            insertPagamento(conn, idPagamento, idCliente, idReserva, total);

            conn.commit();
            return idReserva;
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException ignored) {
            }
            conn.close();
        }
    }

    private float computeTotal(SugestaoViagem sugestao, CriarSugestaoRequest pedido) {
        if (sugestao != null && sugestao.precoEstimadoTotal > 0) {
            return (float) sugestao.precoEstimadoTotal;
        }
        float sum = 0;
        if (pedido.vooIdaSelecionado != null) {
            sum += (float) pedido.vooIdaSelecionado.precoTotal;
        }
        if (pedido.vooRegressoSelecionado != null) {
            sum += (float) pedido.vooRegressoSelecionado.precoTotal;
        }
        if (pedido.hotelSelecionado != null) {
            sum += (float) pedido.hotelSelecionado.precoEstimado;
        }
        return sum > 0 ? sum : 0;
    }

    private void insertReserva(Connection conn, int idReserva, int idCliente, float total) throws SQLException {
        String sql = "INSERT INTO RESERVA (idReserva, data_reserva, total_pagar, estado, idCliente, idPacote) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idReserva);
            stmt.setDate(2, Date.valueOf(LocalDate.now()));
            stmt.setFloat(3, total);
            stmt.setString(4, "Pendente");
            stmt.setInt(5, idCliente);
            stmt.setNull(6, Types.INTEGER);
            stmt.executeUpdate();
        }
    }

    private void updateReservaPacote(Connection conn, int idReserva, int idPacote) throws SQLException {
        String sql = "UPDATE RESERVA SET idPacote = ? WHERE idReserva = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPacote);
            stmt.setInt(2, idReserva);
            stmt.executeUpdate();
        }
    }

    private void insertPacote(Connection conn, int idPacote, int idReserva, CriarSugestaoRequest pedido, SugestaoViagem sugestao) throws SQLException {
        String nome = sugestao != null && notBlank(sugestao.titulo) ? sugestao.titulo.trim() : "Viagem " + safe(pedido.destino);
        String descricao = "";
        if (sugestao != null) {
            if (notBlank(sugestao.resumoFinal)) {
                descricao = sugestao.resumoFinal.trim();
            } else if (notBlank(sugestao.descricao)) {
                descricao = sugestao.descricao.trim();
            }
        }
        float preco = computeTotal(sugestao, pedido);
        int adultos = pedido.adultos > 0 ? pedido.adultos : 1;
        int criancas = Math.max(0, pedido.criancas);

        String sql = "INSERT INTO PACOTE (idPacote, descricao, nome, preco_base, numero_pessoas_adultas, numero_criancas, idReserva) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPacote);
            stmt.setString(2, descricao);
            stmt.setString(3, nome);
            stmt.setFloat(4, preco);
            stmt.setInt(5, adultos);
            stmt.setInt(6, criancas);
            stmt.setInt(7, idReserva);
            stmt.executeUpdate();
        }
    }

    private void insertViagem(Connection conn, int idViagem, CriarSugestaoRequest pedido, VooInfo voo, String tripDate) throws SQLException {
        int adultos = pedido.adultos > 0 ? pedido.adultos : 1;
        int criancas = Math.max(0, pedido.criancas);
        String origem = voo.origem != null && !voo.origem.isBlank() ? voo.origem : pedido.origem;
        String destino = voo.destino != null && !voo.destino.isBlank() ? voo.destino : pedido.destino;
        String empresa = voo.companhia != null ? voo.companhia : "";
        String descricao = buildFlightDescricao(voo);
        float preco = (float) voo.precoTotal;
        Timestamp partida = parseDateTime(tripDate, voo.partida);
        Timestamp chegada = parseDateTime(tripDate, voo.chegada);
        if (chegada == null && partida != null) {
            chegada = partida;
        }

        String sql = "INSERT INTO VIAGENS (idViagem, numero_bilhetes_adulto, numero_bilhetes_crianca, preco, origem, destino, data_hora_partida, data_hora_regresso, descricao, empresa) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idViagem);
            stmt.setInt(2, adultos);
            stmt.setInt(3, criancas);
            stmt.setFloat(4, preco);
            stmt.setString(5, origem);
            stmt.setString(6, destino);
            if (partida != null) {
                stmt.setTimestamp(7, partida);
            } else {
                stmt.setNull(7, Types.TIMESTAMP);
            }
            if (chegada != null) {
                stmt.setTimestamp(8, chegada);
            } else {
                stmt.setNull(8, Types.TIMESTAMP);
            }
            stmt.setString(9, descricao);
            stmt.setString(10, empresa);
            stmt.executeUpdate();
        }
    }

    private String buildFlightDescricao(VooInfo voo) {
        StringBuilder sb = new StringBuilder();
        if (notBlank(voo.numeroVoo)) {
            sb.append(voo.numeroVoo.trim());
        }
        if (notBlank(voo.duracao)) {
            if (sb.length() > 0) {
                sb.append(" · ");
            }
            sb.append(voo.duracao.trim());
        }
        return sb.length() > 0 ? sb.toString() : "Voo selecionado";
    }

    private void insertAlojamento(Connection conn, int idAlojamento, CriarSugestaoRequest pedido, HotelSugestao hotel) throws SQLException {
        int pessoas = Math.max(1, (pedido.adultos > 0 ? pedido.adultos : 1) + Math.max(0, pedido.criancas));
        String morada = hotel.zona != null && !hotel.zona.isBlank() ? hotel.zona : safe(pedido.destino);
        String tipoQuarto = hotel.categoria != null && !hotel.categoria.isBlank() ? hotel.categoria : "Standard";
        String tipoEstadia = hotel.categoria != null && !hotel.categoria.isBlank() ? hotel.categoria : "Hotel";
        float preco = (float) hotel.precoEstimado;

        String sql = "INSERT INTO ALOJAMENTO (idAlojamento, nome, morada, num_pessoas, tipo_quarto, tipo_estadia, preco) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idAlojamento);
            stmt.setString(2, hotel.nome);
            stmt.setString(3, morada);
            stmt.setInt(4, pessoas);
            stmt.setString(5, tipoQuarto);
            stmt.setString(6, tipoEstadia);
            stmt.setFloat(7, preco);
            stmt.executeUpdate();
        }
    }

    private void insertTransporte(Connection conn, int idTransporte, CriarSugestaoRequest pedido, String sugestaoTexto) throws SQLException {
        int lugares = Math.max(1, (pedido.adultos > 0 ? pedido.adultos : 1) + Math.max(0, pedido.criancas));
        String origem = safe(pedido.origem);
        String destino = safe(pedido.destino);
        String descricao = sugestaoTexto.length() > 200 ? sugestaoTexto.substring(0, 200) : sugestaoTexto;

        String sql = "INSERT INTO TRANSPORTE (idTransporte, empresa, tipo, origem, destino, data_hora_partida, data_hora_chegada, preco, lugares) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idTransporte);
            stmt.setString(2, "TravelExplorer");
            stmt.setString(3, "Transfer");
            stmt.setString(4, origem);
            stmt.setString(5, destino);
            stmt.setNull(6, Types.TIMESTAMP);
            stmt.setNull(7, Types.TIMESTAMP);
            stmt.setFloat(8, 0);
            stmt.setInt(9, lugares);
            stmt.executeUpdate();
        }
    }

    private void insertPagamento(Connection conn, int idPagamento, int idCliente, int idReserva, float valor) throws SQLException {
        String sql = "INSERT INTO PAGAMENTO (idPagamento, valor, metodo, data_pagamento, idCliente, idReserva) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPagamento);
            stmt.setFloat(2, valor);
            stmt.setString(3, "Simulado");
            stmt.setNull(4, Types.DATE);
            stmt.setInt(5, idCliente);
            stmt.setInt(6, idReserva);
            stmt.executeUpdate();
        }
    }

    private void linkPacoteViagem(Connection conn, int idPacote, int idViagem) throws SQLException {
        String sql = "INSERT IGNORE INTO PACOTE_VIAGENS (idPacote, idViagem) VALUES (?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPacote);
            stmt.setInt(2, idViagem);
            stmt.executeUpdate();
        }
    }

    private void linkPacoteAlojamento(Connection conn, int idPacote, int idAlojamento) throws SQLException {
        String sql = "INSERT IGNORE INTO PACOTE_ALOJAMENTO (idPacote, idAlojamento) VALUES (?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPacote);
            stmt.setInt(2, idAlojamento);
            stmt.executeUpdate();
        }
    }

    private void linkPacoteTransporte(Connection conn, int idPacote, int idTransporte) throws SQLException {
        String sql = "INSERT IGNORE INTO PACOTE_TRANSPORTE (idPacote, idTransporte) VALUES (?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPacote);
            stmt.setInt(2, idTransporte);
            stmt.executeUpdate();
        }
    }

    private int nextId(Connection conn, String table, String column) throws SQLException {
        String sql = "SELECT COALESCE(MAX(" + column + "), 0) + 1 FROM " + table;
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 1;
    }

    private Timestamp parseDateTime(String datePart, String timeOrDateTime) {
        if (timeOrDateTime == null || timeOrDateTime.isBlank()) {
            if (datePart != null && datePart.length() >= 10) {
                return Timestamp.valueOf(LocalDate.parse(datePart.substring(0, 10)).atStartOfDay());
            }
            return null;
        }
        String value = timeOrDateTime.trim();
        if (value.contains("T")) {
            try {
                return Timestamp.valueOf(LocalDateTime.parse(value.length() > 19 ? value.substring(0, 19) : value));
            } catch (DateTimeParseException ignored) {
            }
        }
        if (datePart != null && datePart.length() >= 10) {
            String date = datePart.substring(0, 10);
            if (value.matches("\\d{1,2}:\\d{2}(:\\d{2})?")) {
                String time = value.length() == 5 ? value + ":00" : value;
                try {
                    return Timestamp.valueOf(LocalDateTime.parse(date + "T" + time));
                } catch (DateTimeParseException ignored) {
                }
            }
            try {
                return Timestamp.valueOf(LocalDate.parse(date).atStartOfDay());
            } catch (DateTimeParseException ignored) {
            }
        }
        try {
            return Timestamp.valueOf(LocalDateTime.parse(value, DateTimeFormatter.ISO_DATE_TIME));
        } catch (DateTimeParseException ignored) {
            return null;
        }
    }

    private static boolean notBlank(String value) {
        return value != null && !value.trim().isEmpty();
    }

    private static String safe(String value) {
        return value != null ? value.trim() : "";
    }
}
