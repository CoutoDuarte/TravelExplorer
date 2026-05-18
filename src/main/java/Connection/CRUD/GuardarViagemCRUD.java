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
import Connection.Classes.TransporteSugerido;
import Connection.Classes.VooInfo;

import java.util.ArrayList;
import java.util.List;

public class GuardarViagemCRUD {

    public int guardar(int idCliente, CriarSugestaoRequest pedido, SugestaoViagem sugestao) throws SQLException {
        Connection conn = DBConnection.getConnection();
        conn.setAutoCommit(false);
        try {
            float total = computeTotal(sugestao, pedido);
            int idReserva = nextId(conn, "RESERVA", "idReserva");
            int idPacote = nextId(conn, "PACOTE", "idPacote");

            insertReserva(conn, idReserva, idCliente, pedido, sugestao, total);
            insertPacote(conn, idPacote, idReserva, pedido, sugestao);
            updateReservaPacote(conn, idReserva, idPacote);

            saveFlightLeg(conn, idPacote, pedido, pedido.vooIdaSelecionado, pedido.dataPartida, "Ida");
            saveFlightLeg(conn, idPacote, pedido, pedido.vooRegressoSelecionado, pedido.dataRegresso, "Regresso");

            if (pedido.hotelSelecionado != null && notBlank(pedido.hotelSelecionado.nome)) {
                int idAlojamento = nextId(conn, "ALOJAMENTO", "idAlojamento");
                insertAlojamento(conn, idAlojamento, pedido, pedido.hotelSelecionado);
                linkPacoteAlojamento(conn, idPacote, idAlojamento);
            }

            if (sugestao != null && sugestao.transporte != null && notBlank(sugestao.transporte.tipo)) {
                int idTransporte = nextId(conn, "TRANSPORTE", "idTransporte");
                insertTransporteStructured(conn, idTransporte, pedido, sugestao.transporte);
                linkPacoteTransporte(conn, idPacote, idTransporte);
            } else if (sugestao != null && notBlank(sugestao.transporteSugerido)) {
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

    private void insertReserva(Connection conn, int idReserva, int idCliente, CriarSugestaoRequest pedido, SugestaoViagem sugestao, float total) throws SQLException {
        String titulo = buildTitulo(pedido, sugestao);
        String sql = "INSERT INTO RESERVA (idReserva, data_reserva, total_pagar, estado, idCliente, idPacote, origem, destino, data_partida, data_regresso, adultos, criancas, titulo) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idReserva);
            stmt.setDate(2, Date.valueOf(LocalDate.now()));
            stmt.setFloat(3, total);
            stmt.setString(4, "Pendente");
            stmt.setInt(5, idCliente);
            stmt.setNull(6, Types.INTEGER);
            stmt.setString(7, safe(pedido.origem));
            stmt.setString(8, safe(pedido.destino));
            setDate(stmt, 9, pedido.dataPartida);
            setDate(stmt, 10, pedido.dataRegresso);
            stmt.setInt(11, pedido.adultos > 0 ? pedido.adultos : 1);
            stmt.setInt(12, Math.max(0, pedido.criancas));
            stmt.setString(13, titulo);
            stmt.executeUpdate();
        }
    }

    private String buildTitulo(CriarSugestaoRequest pedido, SugestaoViagem sugestao) {
        if (sugestao != null && notBlank(sugestao.titulo)) {
            return sugestao.titulo.trim();
        }
        if (notBlank(pedido.origem) && notBlank(pedido.destino)) {
            return pedido.origem.trim() + " → " + pedido.destino.trim();
        }
        return "Viagem personalizada";
    }

    private void setDate(PreparedStatement stmt, int index, String isoDate) throws SQLException {
        if (isoDate == null || isoDate.isBlank()) {
            stmt.setNull(index, Types.DATE);
            return;
        }
        String value = isoDate.trim();
        if (value.length() >= 10) {
            value = value.substring(0, 10);
        }
        try {
            stmt.setDate(index, Date.valueOf(LocalDate.parse(value)));
        } catch (Exception e) {
            stmt.setNull(index, Types.DATE);
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
        String descricao = buildPacoteDescricao(pedido, sugestao);
        float preco = computeTotal(sugestao, pedido);
        int adultos = pedido.adultos > 0 ? pedido.adultos : 1;
        int criancas = Math.max(0, pedido.criancas);

        String sql = "INSERT INTO PACOTE (idPacote, descricao, nome, preco_base, numero_pessoas_adultas, numero_criancas, idReserva, tipo, imagem_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPacote);
            stmt.setString(2, descricao);
            stmt.setString(3, nome);
            stmt.setFloat(4, preco);
            stmt.setInt(5, adultos);
            stmt.setInt(6, criancas);
            stmt.setInt(7, idReserva);
            stmt.setString(8, "Reserva");
            stmt.setNull(9, Types.VARCHAR);
            stmt.executeUpdate();
        }
    }

    private void saveFlightLeg(Connection conn, int idPacote, CriarSugestaoRequest pedido, VooInfo voo, String tripDate, String direcao) throws SQLException {
        if (voo == null) {
            return;
        }
        List<VooInfo> segments = (voo.segmentos != null && !voo.segmentos.isEmpty()) ? voo.segmentos : new ArrayList<>();
        if (segments.isEmpty()) {
            segments.add(voo);
        }
        int totalSeg = segments.size();
        for (int i = 0; i < totalSeg; i++) {
            VooInfo seg = segments.get(i);
            int idViagem = nextId(conn, "VIAGENS", "idViagem");
            float preco = (i == 0) ? (float) voo.precoTotal : 0f;
            String descricao = direcao;
            if (totalSeg > 1) {
                descricao += " · Segmento " + (i + 1);
            }
            String detalhe = buildFlightDescricao(seg);
            if (notBlank(detalhe)) {
                descricao += " · " + detalhe;
            }
            insertViagem(conn, idViagem, pedido, seg, tripDate, preco, descricao);
            linkPacoteViagem(conn, idPacote, idViagem);
        }
    }

    private void insertViagem(Connection conn, int idViagem, CriarSugestaoRequest pedido, VooInfo voo, String tripDate, float preco, String descricao) throws SQLException {
        int adultos = pedido.adultos > 0 ? pedido.adultos : 1;
        int criancas = Math.max(0, pedido.criancas);
        String origem = voo.origem != null && !voo.origem.isBlank() ? voo.origem : pedido.origem;
        String destino = voo.destino != null && !voo.destino.isBlank() ? voo.destino : pedido.destino;
        String empresa = voo.companhia != null ? voo.companhia : "";
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
        String categoriaHotel = buildHotelCategoryLabel(hotel);
        String tipoQuarto = categoriaHotel;
        String tipoEstadia = categoriaHotel;
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

    private void insertTransporteStructured(Connection conn, int idTransporte, CriarSugestaoRequest pedido, TransporteSugerido t) throws SQLException {
        int lugares = Math.max(1, (pedido.adultos > 0 ? pedido.adultos : 1) + Math.max(0, pedido.criancas));
        String tipo = notBlank(t.tipo) ? t.tipo.trim() : "Transfer";
        if (notBlank(t.duracao)) {
            tipo = tipo + " - " + t.duracao.trim();
        }
        String origem = notBlank(t.origem) ? t.origem.trim() : resolveTransportOrigem(pedido);
        String destino = notBlank(t.destino) ? t.destino.trim() : resolveTransportDestino(pedido);
        String empresa = "TravelExplorer";
        float preco = t.precoEstimado > 0 ? (float) t.precoEstimado : 0f;

        String sql = "INSERT INTO TRANSPORTE (idTransporte, empresa, tipo, origem, destino, data_hora_partida, data_hora_chegada, preco, lugares) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idTransporte);
            stmt.setString(2, empresa);
            stmt.setString(3, tipo);
            stmt.setString(4, origem);
            stmt.setString(5, destino);
            stmt.setNull(6, Types.TIMESTAMP);
            stmt.setNull(7, Types.TIMESTAMP);
            stmt.setFloat(8, preco);
            stmt.setInt(9, lugares);
            stmt.executeUpdate();
        }
    }

    private void insertTransporte(Connection conn, int idTransporte, CriarSugestaoRequest pedido, String sugestaoTexto) throws SQLException {
        int lugares = Math.max(1, (pedido.adultos > 0 ? pedido.adultos : 1) + Math.max(0, pedido.criancas));
        String origem = resolveTransportOrigem(pedido);
        String destino = resolveTransportDestino(pedido);
        String tipo = detectTransportTipo(sugestaoTexto);
        String empresa = resolveTransportEmpresa(sugestaoTexto);

        String sql = "INSERT INTO TRANSPORTE (idTransporte, empresa, tipo, origem, destino, data_hora_partida, data_hora_chegada, preco, lugares) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idTransporte);
            stmt.setString(2, empresa);
            stmt.setString(3, tipo);
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
        String sql = "INSERT INTO PAGAMENTO (idPagamento, valor, metodo, data_pagamento, idCliente, idReserva, estado, referencia) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPagamento);
            stmt.setFloat(2, valor);
            stmt.setString(3, "Simulado");
            stmt.setNull(4, Types.DATE);
            stmt.setInt(5, idCliente);
            stmt.setInt(6, idReserva);
            stmt.setString(7, "Pendente");
            stmt.setNull(8, Types.VARCHAR);
            stmt.executeUpdate();
        }
    }

    private String buildPacoteDescricao(CriarSugestaoRequest pedido, SugestaoViagem sugestao) {
        StringBuilder sb = new StringBuilder();
        if (sugestao != null) {
            if (notBlank(sugestao.resumoFinal)) {
                sb.append(sugestao.resumoFinal.trim());
            } else if (notBlank(sugestao.descricao)) {
                sb.append(sugestao.descricao.trim());
            }
        }
        if (sugestao != null && sugestao.atividades != null && !sugestao.atividades.isEmpty()) {
            if (sb.length() > 0) sb.append("\n\n");
            sb.append("Atividades sugeridas:\n");
            for (String atividade : sugestao.atividades) {
                if (notBlank(atividade)) {
                    sb.append("- ").append(atividade.trim()).append('\n');
                }
            }
        }
        if (sugestao != null && notBlank(sugestao.transporteSugerido)) {
            if (sb.length() > 0) sb.append("\n");
            sb.append("Transporte sugerido:\n").append(sugestao.transporteSugerido.trim());
        }
        return sb.toString().trim();
    }

    private String buildHotelCategoryLabel(HotelSugestao hotel) {
        if (hotel == null) {
            return "Classificação não disponível";
        }
        if (notBlank(hotel.categoria) && !"hotel".equalsIgnoreCase(hotel.categoria.trim())) {
            return hotel.categoria.trim();
        }
        if (hotel.rating > 0) {
            double r = hotel.rating;
            if (r <= 5 && Math.abs(r - Math.round(r)) < 0.01) {
                int n = (int) Math.round(r);
                return n + (n == 1 ? " estrela" : " estrelas");
            }
            return String.format(java.util.Locale.forLanguageTag("pt-PT"), "%.1f avaliação", r);
        }
        return "Classificação não disponível";
    }

    private String resolveTransportOrigem(CriarSugestaoRequest pedido) {
        if (pedido.vooIdaSelecionado != null && notBlank(pedido.vooIdaSelecionado.destino)) {
            return pedido.vooIdaSelecionado.destino.trim();
        }
        return notBlank(pedido.origem) ? pedido.origem.trim() : "Aeroporto";
    }

    private String resolveTransportDestino(CriarSugestaoRequest pedido) {
        if (pedido.hotelSelecionado != null && notBlank(pedido.hotelSelecionado.zona)) {
            return pedido.hotelSelecionado.zona.trim();
        }
        if (pedido.hotelSelecionado != null && notBlank(pedido.hotelSelecionado.nome)) {
            return pedido.hotelSelecionado.nome.trim();
        }
        return notBlank(pedido.destino) ? pedido.destino.trim() : "Destino";
    }

    private String resolveTransportEmpresa(String text) {
        if (!notBlank(text)) return "TravelExplorer";
        String lower = text.toLowerCase();
        if (lower.contains("metro de lisboa") || lower.contains("metropolitano")) return "Metro de Lisboa";
        if (lower.contains("cp ") || lower.contains("comboios de portugal")) return "CP";
        if (lower.contains("uber")) return "Uber";
        if (lower.contains("bolt")) return "Bolt";
        return "TravelExplorer";
    }

    private String detectTransportTipo(String text) {
        if (text == null) {
            return "Transfer";
        }
        String lower = text.toLowerCase();
        if (lower.contains("metro")) return "Metro";
        if (lower.contains("shuttle")) return "Shuttle";
        if (lower.contains("transfer privado") || lower.contains("transfer privada")) return "Transfer privado";
        if (lower.contains("uber") || lower.contains("bolt")) return "Táxi";
        if (lower.contains("táxi") || lower.contains("taxi")) return "Táxi";
        if (lower.contains("comboio") || lower.contains("train") || lower.contains("cp ")) return "Comboio";
        if (lower.contains("autocarro") || lower.contains("bus")) return "Autocarro";
        if (lower.contains("elétrico") || lower.contains("eletrico")) return "Elétrico";
        if (lower.contains("transfer")) return "Transfer";
        return "Transfer";
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
