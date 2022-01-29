class Payment {


  late String IdPedido;
  late String DataHoraPedidoRegistado;
  late String DataHoraPedidoAtualizado;
  late String MsgDescricao;
  late String Referencia;
  late String EmailCliente;
  late String tlmCliente;

  Payment(
      {required this.IdPedido,
        required this.DataHoraPedidoRegistado,
        required this.MsgDescricao,
        required this.DataHoraPedidoAtualizado,
        required this.EmailCliente,
        required this.Referencia,
        required this.tlmCliente,
      });

}
