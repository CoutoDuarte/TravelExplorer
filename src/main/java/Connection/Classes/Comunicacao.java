package Connection.Classes;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Comunicacao {
    private int idComunicacao;
    private String titulo;
    private String canal;
    private String segmento;
    private LocalDate dataComunicacao;
    private String estado;
    private String mensagem;
    private int idCliente;
    private int idReserva;
    private String resposta;
    private LocalDateTime dataResposta;
    private int idFuncionarioResposta;

    public Comunicacao(int idComunicacao, String titulo, String canal, String segmento, LocalDate dataComunicacao,
                       String estado, String mensagem, int idCliente) {
        this(idComunicacao, titulo, canal, segmento, dataComunicacao, estado, mensagem, idCliente, 0, null, null, 0);
    }

    public Comunicacao(int idComunicacao, String titulo, String canal, String segmento, LocalDate dataComunicacao,
                       String estado, String mensagem, int idCliente, int idReserva, String resposta,
                       LocalDateTime dataResposta, int idFuncionarioResposta) {
        this.idComunicacao = idComunicacao;
        this.titulo = titulo;
        this.canal = canal;
        this.segmento = segmento;
        this.dataComunicacao = dataComunicacao;
        this.estado = estado;
        this.mensagem = mensagem;
        this.idCliente = idCliente;
        this.idReserva = idReserva;
        this.resposta = resposta;
        this.dataResposta = dataResposta;
        this.idFuncionarioResposta = idFuncionarioResposta;
    }

    public int getIdComunicacao() { return idComunicacao; }
    public String getTitulo() { return titulo; }
    public String getCanal() { return canal; }
    public String getSegmento() { return segmento; }
    public LocalDate getDataComunicacao() { return dataComunicacao; }
    public String getEstado() { return estado; }
    public String getMensagem() { return mensagem; }
    public int getIdCliente() { return idCliente; }
    public int getIdReserva() { return idReserva; }
    public String getResposta() { return resposta; }
    public LocalDateTime getDataResposta() { return dataResposta; }
    public int getIdFuncionarioResposta() { return idFuncionarioResposta; }
}
