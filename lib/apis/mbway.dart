import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'webservice.dart';
part 'mbway.g.dart';

@JsonSerializable(explicitToJson: true)
class Mbway {
  String IdPedido = '';
  String Valor = '';
  String CodigoMoeda = '9782';
  String Estado = '';
  String DataHora = '';
  String MsgDescricao = '';

  static Resource<Mbway> getRequest(
      {
      String MbWayKey = 'PDY-214580',
      String canal = '03',
      required String referencia,
      required String valor,
        required String nrtlm,
      required String email,
        required String descricao
      }) {

    var mbway = Resource(
        url: '/ifthenpaymbw.asmx/SetPedidoJSON?MbWayKey=${MbWayKey}&canal=${canal}&referencia=${referencia}&valor=${valor}&nrtlm=${nrtlm}&email=${email}&descricao=${descricao}',
        parse: (response) {
          final result = json.decode(response.body);

          var decoded = Mbway.fromJson(result);

          return decoded;
        },
        headers: {});

    return mbway;
  }

  static Resource<dynamic> openDoor() {

    var mbway = Resource(
        url: 'http://161.230.247.85:3333/cgi-bin/accessControl.cgi?action=openDoor&channel=1&UserID=101&Type=Remote',
        parse: (response) {
          final result = json.decode(response.body);

          return result;
        },
        headers: {

        });

    return mbway;
  }

  static Resource<dynamic> getRequestState(
      {
        String MbWayKey = 'PDY-214580',
        String canal = '03',
        required String idPagamento,
      }) {

    var mbway = Resource(
        url: '/ifthenpaymbw.asmx/EstadoPedidosJSON?MbWayKey=${MbWayKey}&canal=${canal}&idspagamento=${idPagamento}',
        parse: (response) {
          final result = json.decode(response.body);
          final toReturn = result['EstadoPedidos'][0];
          //var decoded = Mbway.fromJson(result);

          return toReturn;
        },
        headers: {});

    return mbway;
  }

  Mbway(
      {
  this.CodigoMoeda = '9782',
  this.DataHora = '',
  this.Estado = '',
  this.IdPedido = '',
        this.MsgDescricao = '',
        this.Valor = ''
      });

  factory Mbway.fromJson(Map<String, dynamic> json) => _$MbwayFromJson(json);
}
