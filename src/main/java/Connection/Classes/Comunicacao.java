package Connection.Classes;

import java.time.LocalDate;

public class Comunicacao {
    private int idComunicacao;
    private String titulo;
    private String canal;
    private String segmento;
    private LocalDate dataComunicacao;
    private String estado;
    private String mensagem;
    private int idCliente;

    public Comunicacao(int idComunicacao, String titulo, String canal, String segmento, LocalDate dataComunicacao,
                       String estado, String mensagem, int idCliente) {
        this.idComunicacao = idComunicacao;
        this.titulo = titulo;
        this.canal = canal;
        this.segmento = segmento;
        this.dataComunicacao = dataComunicacao;
        this.estado = estado;
        this.mensagem = mensagem;
        this.idCliente = idCliente;
    }

    public int getIdComunicacao() { return idComunicacao; }
    public String getTitulo() { return titulo; }
    public String getCanal() { return canal; }
    public String getSegmento() { return segmento; }
    public LocalDate getDataComunicacao() { return dataComunicacao; }
    public String getEstado() { return estado; }
    public String getMensagem() { return mensagem; }
    public int getIdCliente() { return idCliente; }
}
