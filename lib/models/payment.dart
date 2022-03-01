import 'package:flutter/material.dart';

class Payment {

  late String IdPedido;
  late String DataHoraPedidoRegistado;
  late String Referencia;
  late String EmailCliente;
  late String tlmCliente;
  late String amount;

  Payment(
      {required this.IdPedido,
        required this.DataHoraPedidoRegistado,
        required this.EmailCliente,
        required this.Referencia,
        required this.tlmCliente,
        required this.amount,
      });

  Map<String, dynamic> toMap(){
    return{
      "IdPedido":IdPedido,
      "DataHoraPedidoRegistado": DataHoraPedidoRegistado,
      "Referencia": Referencia,
      "EmailCliente": EmailCliente,
      "tlmCliente": tlmCliente,
      "amount": amount
    };
  }

}
