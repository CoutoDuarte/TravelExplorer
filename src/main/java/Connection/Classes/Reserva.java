package Connection.Classes;

import java.time.LocalDate;

public class Reserva {
	private int idReserva;
	private LocalDate data_reserva;
	private float total_pagar;
	private String estado;
	private int idCliente;
	private int idPacote;
	
	public Reserva(int idReserva, LocalDate data_reserva, float total_pagar, String estado, int idCliente, int idPacote) {
		this.idReserva = idReserva;
		this.data_reserva = data_reserva;
		this.total_pagar = total_pagar;
		this.estado = estado;
		this.idCliente = idCliente;
		this.idPacote = idPacote;
	}
	
	public int getIdReserva() {return idReserva;}
	public LocalDate getDataReserva() {return data_reserva;}
	public float getTotalPagar() {return total_pagar;}
	public String getEstado() {return estado;}
	public int getIdCliente() {return idCliente;}
	public int getIdPacote() {return idPacote;}
}
