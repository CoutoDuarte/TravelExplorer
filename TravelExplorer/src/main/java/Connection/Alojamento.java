package Connection;

public class Alojamento {
    private int idAlojamento;
    private String nome;
    private String morada;
    private int numPessoas;
    private String tipoQuarto;
    private String tipoEstadia;
    private float preco;

    public Alojamento(int idAlojamento, String nome, String morada, int numPessoas,
                      String tipoQuarto, String tipoEstadia, float preco) {

        this.idAlojamento = idAlojamento;
        this.nome = nome;
        this.morada = morada;
        this.numPessoas = numPessoas;
        this.tipoQuarto = tipoQuarto;
        this.tipoEstadia = tipoEstadia;
        this.preco = preco;
    }

    public int getIdAlojamento() { return idAlojamento; }
    public String getNome() { return nome; }
    public String getMorada() { return morada; }
    public int getNumPessoas() { return numPessoas; }
    public String getTipoQuarto() { return tipoQuarto; }
    public String getTipoEstadia() { return tipoEstadia; }
    public float getPreco() { return preco; }
}