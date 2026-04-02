package Connection;

public class Pacote {
	private int idPacote;
	private String descricao;
	private String nome;
	private float preco_base;
	private int num_adultos;
	private int num_criancas;
	private int idReserva;
	
	public Pacote(int idPacote, String descricao, String nome, float preco_base, int num_adultos, int num_criancas, int idReserva) {
		this.idPacote = idPacote;
		this.descricao = descricao;
		this.nome = nome;
		this.preco_base = preco_base;
		this.num_adultos = num_adultos;
		this.num_criancas = num_criancas;
		this.idReserva = idReserva;
	}
	
	public int getIdPacote() {return idPacote;}
	public String getDescricao() {return descricao;}
	public String getNome() {return nome;}
	public float getPrecoBase() {return preco_base;}
	public int getNumAdultos() {return num_adultos;}
	public int getNumCriancas() {return num_criancas;}
	public int getIdReserva() { return idReserva;}
}
