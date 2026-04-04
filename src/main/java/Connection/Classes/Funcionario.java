package Connection.Classes;

public class Funcionario {
	private int idFuncionario;
	private String nome;
	private String email;
	private int telemovel;
	private float salario;
	
	public Funcionario(int idFuncionario, String nome, String email, int telemovel, float salario) {
		this.idFuncionario = idFuncionario;
		this.nome = nome;
		this.email = email;
		this.telemovel = telemovel;
		this.salario = salario;
	}
	
	public int getIdFuncionario() {return idFuncionario;}
	public String getNome() {return nome;}
	public String getEmail() {return email;}
	public int getTelemovel() {return telemovel;}
	public float getSalario() {return salario;}
	
}
