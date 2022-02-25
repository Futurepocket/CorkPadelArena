class Payment {


  late String IdPedido;
  late String DataHoraPedidoRegistado;
  late String Referencia;
  late String EmailCliente;
  late String tlmCliente;

  Payment(
      {required this.IdPedido,
        required this.DataHoraPedidoRegistado,
        required this.EmailCliente,
        required this.Referencia,
        required this.tlmCliente,
      });

  Map<String, dynamic> toMap(){
    return{
      "IdPedido":IdPedido,
      "DataHoraPedidoRegistado": DataHoraPedidoRegistado,
      "Referencia": Referencia,
      "EmailCliente": EmailCliente,
      "tlmCliente": tlmCliente,
    };
  }

}
