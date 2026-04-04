package Connection.Classes;

public class Permissao {
    private int idPermissao;
    private String nome;
    private String descricao;

    public Permissao(int idPermissao, String nome, String descricao) {
        this.idPermissao = idPermissao;
        this.nome = nome;
        this.descricao = descricao;
    }

    public int getIdPermissao() { return idPermissao; }
    public String getNome() { return nome; }
    public String getDescricao() { return descricao; }
}