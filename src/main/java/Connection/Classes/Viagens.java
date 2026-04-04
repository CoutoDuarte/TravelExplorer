package Connection.Classes;

import java.sql.Timestamp;

public class Viagens {
    private int idViagem;
    private int numBilhetesAdulto;
    private int numBilhetesCrianca;
    private float preco;
    private String origem;
    private String destino;
    private Timestamp dataHoraPartida;
    private Timestamp dataHoraRegresso;
    private String descricao;
    private String empresa;

    public Viagens(int idViagem, int numBilhetesAdulto, int numBilhetesCrianca, float preco,
                   String origem, String destino, Timestamp dataHoraPartida,
                   Timestamp dataHoraRegresso, String descricao, String empresa) {

        this.idViagem = idViagem;
        this.numBilhetesAdulto = numBilhetesAdulto;
        this.numBilhetesCrianca = numBilhetesCrianca;
        this.preco = preco;
        this.origem = origem;
        this.destino = destino;
        this.dataHoraPartida = dataHoraPartida;
        this.dataHoraRegresso = dataHoraRegresso;
        this.descricao = descricao;
        this.empresa = empresa;
    }

    public int getIdViagem() { return idViagem; }
    public int getNumBilhetesAdulto() { return numBilhetesAdulto; }
    public int getNumBilhetesCrianca() { return numBilhetesCrianca; }
    public float getPreco() { return preco; }
    public String getOrigem() { return origem; }
    public String getDestino() { return destino; }
    public Timestamp getDataHoraPartida() { return dataHoraPartida; }
    public Timestamp getDataHoraRegresso() { return dataHoraRegresso; }
    public String getDescricao() { return descricao; }
    public String getEmpresa() { return empresa; }
}