package Connection.Classes;

public class ClienteOfertaGuardada {
    private int idCliente;
    private int idPacote;
    private String dataGuardado;
    private String nomePacote;
    private String descricaoPacote;
    private double precoBase;
    private int numeroPessoasAdultas;
    private int numeroCriancas;
    private String destino;
    private String origem;
    private String dataPartida;
    private String dataRegresso;
    private String alojamentoNome;
    private String tipoEstadia;

    public ClienteOfertaGuardada() {
    }

    public ClienteOfertaGuardada(int idCliente, int idPacote, String dataGuardado, String nomePacote, String descricaoPacote, double precoBase, int numeroPessoasAdultas, int numeroCriancas, String destino, String origem, String dataPartida, String dataRegresso, String alojamentoNome, String tipoEstadia) {
        this.idCliente = idCliente;
        this.idPacote = idPacote;
        this.dataGuardado = dataGuardado;
        this.nomePacote = nomePacote;
        this.descricaoPacote = descricaoPacote;
        this.precoBase = precoBase;
        this.numeroPessoasAdultas = numeroPessoasAdultas;
        this.numeroCriancas = numeroCriancas;
        this.destino = destino;
        this.origem = origem;
        this.dataPartida = dataPartida;
        this.dataRegresso = dataRegresso;
        this.alojamentoNome = alojamentoNome;
        this.tipoEstadia = tipoEstadia;
    }

    public int getIdCliente() {
        return idCliente;
    }

    public void setIdCliente(int idCliente) {
        this.idCliente = idCliente;
    }

    public int getIdPacote() {
        return idPacote;
    }

    public void setIdPacote(int idPacote) {
        this.idPacote = idPacote;
    }

    public String getDataGuardado() {
        return dataGuardado;
    }

    public void setDataGuardado(String dataGuardado) {
        this.dataGuardado = dataGuardado;
    }

    public String getNomePacote() {
        return nomePacote;
    }

    public void setNomePacote(String nomePacote) {
        this.nomePacote = nomePacote;
    }

    public String getDescricaoPacote() {
        return descricaoPacote;
    }

    public void setDescricaoPacote(String descricaoPacote) {
        this.descricaoPacote = descricaoPacote;
    }

    public double getPrecoBase() {
        return precoBase;
    }

    public void setPrecoBase(double precoBase) {
        this.precoBase = precoBase;
    }

    public int getNumeroPessoasAdultas() {
        return numeroPessoasAdultas;
    }

    public void setNumeroPessoasAdultas(int numeroPessoasAdultas) {
        this.numeroPessoasAdultas = numeroPessoasAdultas;
    }

    public int getNumeroCriancas() {
        return numeroCriancas;
    }

    public void setNumeroCriancas(int numeroCriancas) {
        this.numeroCriancas = numeroCriancas;
    }

    public String getDestino() {
        return destino;
    }

    public void setDestino(String destino) {
        this.destino = destino;
    }

    public String getOrigem() {
        return origem;
    }

    public void setOrigem(String origem) {
        this.origem = origem;
    }

    public String getDataPartida() {
        return dataPartida;
    }

    public void setDataPartida(String dataPartida) {
        this.dataPartida = dataPartida;
    }

    public String getDataRegresso() {
        return dataRegresso;
    }

    public void setDataRegresso(String dataRegresso) {
        this.dataRegresso = dataRegresso;
    }

    public String getAlojamentoNome() {
        return alojamentoNome;
    }

    public void setAlojamentoNome(String alojamentoNome) {
        this.alojamentoNome = alojamentoNome;
    }

    public String getTipoEstadia() {
        return tipoEstadia;
    }

    public void setTipoEstadia(String tipoEstadia) {
        this.tipoEstadia = tipoEstadia;
    }
}
