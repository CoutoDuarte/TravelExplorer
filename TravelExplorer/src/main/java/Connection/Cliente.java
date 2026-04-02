package Connection;

import java.time.LocalDate;

public class Cliente {
	private int idCliente;
	private String nome;
	private String email;
	private String morada;
	private int NIF;
	private int telemovel;
	private LocalDate data_nascimento;
	
	public Cliente(int idCliente, String nome, String email, String morada, int NIF, int telemovel, LocalDate data_nascimento) {
		this.idCliente = idCliente;
		this.nome = nome;
		this.email = email;
		this.morada = morada;
		this.NIF = NIF;
		this.telemovel = telemovel;
		this.data_nascimento = data_nascimento;
	}
	
	public int getIdCliente() {return idCliente;}
	public String getNome() {return nome;}
	public String getEmail() {return email;}
	public String getMorada() {return morada;}
	public int getNIF() {return NIF;}
	public int getTelemovel() {return telemovel;}
	public LocalDate getDataNasc() {return data_nascimento;}
	
}
