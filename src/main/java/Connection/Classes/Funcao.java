package Connection.Classes;

public class Funcao {
    private int idFuncao;
    private String nome;
    private String descricao;

    public Funcao(int idFuncao, String nome, String descricao) {
        this.idFuncao = idFuncao;
        this.nome = nome;
        this.descricao = descricao;
    }

    public int getIdFuncao() { return idFuncao; }
    public String getNome() { return nome; }
    public String getDescricao() { return descricao; }
}