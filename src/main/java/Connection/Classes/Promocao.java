package Connection.Classes;

import java.time.LocalDate;

public class Promocao {
    private int idPromocao;
    private String titulo;
    private String destino;
    private LocalDate periodoInicio;
    private LocalDate periodoFim;
    private String condicao;
    private String estado;
    private int idPacote;

    public Promocao(int idPromocao, String titulo, String destino, LocalDate periodoInicio, LocalDate periodoFim,
                    String condicao, String estado, int idPacote) {
        this.idPromocao = idPromocao;
        this.titulo = titulo;
        this.destino = destino;
        this.periodoInicio = periodoInicio;
        this.periodoFim = periodoFim;
        this.condicao = condicao;
        this.estado = estado;
        this.idPacote = idPacote;
    }

    public int getIdPromocao() { return idPromocao; }
    public String getTitulo() { return titulo; }
    public String getDestino() { return destino; }
    public LocalDate getPeriodoInicio() { return periodoInicio; }
    public LocalDate getPeriodoFim() { return periodoFim; }
    public String getCondicao() { return condicao; }
    public String getEstado() { return estado; }
    public int getIdPacote() { return idPacote; }
}
