package Connection.Classes;

import java.sql.Date;

public class Pagamento {
    private int idPagamento;
    private float valor;
    private String metodo;
    private Date dataPagamento;
    private int idCliente;
    private int idReserva;

    public Pagamento(int idPagamento, float valor, String metodo, Date dataPagamento, int idCliente, int idReserva) {
        this.idPagamento = idPagamento;
        this.valor = valor;
        this.metodo = metodo;
        this.dataPagamento = dataPagamento;
        this.idCliente = idCliente;
        this.idReserva = idReserva;
    }

    public int getIdPagamento() { return idPagamento; }
    public float getValor() { return valor; }
    public String getMetodo() { return metodo; }
    public Date getDataPagamento() { return dataPagamento; }
    public int getIdCliente() { return idCliente; }
    public int getIdReserva() { return idReserva; }
}