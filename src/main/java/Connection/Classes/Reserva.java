package Connection.Classes;

import java.time.LocalDate;

public class Reserva {
    private int idReserva;
    private LocalDate data_reserva;
    private float total_pagar;
    private String estado;
    private int idCliente;
    private int idPacote;
    private String origem;
    private String destino;
    private LocalDate dataPartida;
    private LocalDate dataRegresso;
    private int adultos;
    private int criancas;
    private String titulo;

    public Reserva(int idReserva, LocalDate data_reserva, float total_pagar, String estado, int idCliente, int idPacote) {
        this.idReserva = idReserva;
        this.data_reserva = data_reserva;
        this.total_pagar = total_pagar;
        this.estado = estado;
        this.idCliente = idCliente;
        this.idPacote = idPacote;
        this.adultos = 1;
        this.criancas = 0;
    }

    public int getIdReserva() { return idReserva; }
    public LocalDate getDataReserva() { return data_reserva; }
    public float getTotalPagar() { return total_pagar; }
    public String getEstado() { return estado; }
    public int getIdCliente() { return idCliente; }
    public int getIdPacote() { return idPacote; }
    public String getOrigem() { return origem; }
    public String getDestino() { return destino; }
    public LocalDate getDataPartida() { return dataPartida; }
    public LocalDate getDataRegresso() { return dataRegresso; }
    public int getAdultos() { return adultos; }
    public int getCriancas() { return criancas; }
    public String getTitulo() { return titulo; }
    public void setIdPacote(int idPacote) { this.idPacote = idPacote; }
    public void setOrigem(String origem) { this.origem = origem; }
    public void setDestino(String destino) { this.destino = destino; }
    public void setDataPartida(LocalDate dataPartida) { this.dataPartida = dataPartida; }
    public void setDataRegresso(LocalDate dataRegresso) { this.dataRegresso = dataRegresso; }
    public void setAdultos(int adultos) { this.adultos = adultos; }
    public void setCriancas(int criancas) { this.criancas = criancas; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
}
