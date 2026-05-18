package Connection.Classes;

import java.util.ArrayList;
import java.util.List;

public class VooInfo {
    public String companhia;
    public String numeroVoo;
    public String origem;
    public String destino;
    public String aeroportoOrigem;
    public String aeroportoDestino;
    public String partida;
    public String chegada;
    public String duracao;
    public double precoPorPessoa;
    public double precoTotal;
    public int numEscalas;
    public List<VooInfo> segmentos = new ArrayList<>();
}
