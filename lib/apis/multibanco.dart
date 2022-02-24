import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'webservice.dart';
part 'multibanco.g.dart';

@JsonSerializable(explicitToJson: true)
class Multibanco {
  String Amount = '';
  String Entity = '';
  String ExpiryDate = '';
  String Message = '';
  String OrderId = '';
  String Reference = '';
  String RequestId = '';
  String Status ='';

  static Resource<Multibanco> postRequest(
      {
        required String orderId,
        required String amount,
        required String description,
        required String clientName,
        required String clientEmail,
        required String clientUsername,
        required String clientPhone,
      }) {
    const String MBKEY = 'BFZ-560841';
    const String url = 'https://corkpadelarena.com/#/login';
    const String expiryDays = '1';

    var multibanco = Resource(
        url: '/multibanco/reference/init',
        body: jsonEncode({
          "mbKey": MBKEY,
          "orderId": orderId,
          "amount": amount,
          "description": description,
          "url": url,
          "clientName": clientName,
          "clientEmail": clientEmail,
          "clientUsername": clientUsername,
          "clientPhone": clientPhone,
          "expiryDays" : expiryDays
        }),
        parse: (response) {
          final result = json.decode(response.body);

          var decoded = Multibanco.fromJson(result);
          return decoded;
        },
        headers: {});

    return multibanco;
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


  Multibanco(
      {this.Amount = '',
      this.Entity = '',
      this.ExpiryDate = '',
      this.Message = '',
      this.OrderId = '',
      this.Reference = '',
      this.RequestId = '',
      this.Status = ''});

  factory Multibanco.fromJson(Map<String, dynamic> json) => _$MultibancoFromJson(json);
}
