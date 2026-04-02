package Connection;

import java.sql.Timestamp;

public class Transporte {
    private int idTransporte;
    private String empresa;
    private String tipo;
    private String origem;
    private String destino;
    private Timestamp dataHoraPartida;
    private Timestamp dataHoraChegada;
    private float preco;
    private int lugares;

    public Transporte(int idTransporte, String empresa, String tipo, String origem,
                      String destino, Timestamp dataHoraPartida,
                      Timestamp dataHoraChegada, float preco, int lugares) {

        this.idTransporte = idTransporte;
        this.empresa = empresa;
        this.tipo = tipo;
        this.origem = origem;
        this.destino = destino;
        this.dataHoraPartida = dataHoraPartida;
        this.dataHoraChegada = dataHoraChegada;
        this.preco = preco;
        this.lugares = lugares;
    }

    public int getIdTransporte() { return idTransporte; }
    public String getEmpresa() { return empresa; }
    public String getTipo() { return tipo; }
    public String getOrigem() { return origem; }
    public String getDestino() { return destino; }
    public Timestamp getDataHoraPartida() { return dataHoraPartida; }
    public Timestamp getDataHoraChegada() { return dataHoraChegada; }
    public float getPreco() { return preco; }
    public int getLugares() { return lugares; }
}