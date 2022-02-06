import 'dart:convert';
import 'package:cork_padel_arena/apis/multibanco.dart';
import 'package:cork_padel_arena/apis/webservice.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/view/mbway_payment.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cork_padel_arena/models/checkoutValue.dart';

class Checkout extends StatefulWidget {
  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {

  checkoutValue _check = checkoutValue();
  var ws = Webservice();


  void _showMb({
    required String entity,
    required String reference,
    required String amount,
    required String expiryDate,
    required String error
  }){
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text('Pagamento Multibanco'),
                content: SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child:
                  Error != ''?
                  ListBody(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Entidade: $entity',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'Referencia: $reference',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'Valor: € $amount.00',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'Expira em: $expiryDate',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ):
                      ListBody(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(
                                'Erro: ${Error}',
                    style: const TextStyle(fontSize: 16),
                  ))
                      ],)
                ),
                actions: <Widget>[
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancelar",
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                    },
                    child: Text(
                      "APROVADO",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              );
            }
        );
      },
    );
  }
  DatabaseReference database = FirebaseDatabase.instance.ref();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text("Pagamento"),
          backgroundColor: Theme.of(context).primaryColor),
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                'assets/images/logo.png',
                width: 80.0,
                height: 100.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Pagamento',
                style: TextStyle(
                  fontFamily: 'Roboto Condensed',
                  fontSize: 26,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Valor total: € ${_check.price.toString()}.00',
                style: TextStyle(
                  fontFamily: 'Roboto Condensed',
                  fontSize: 24,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                    icon: Image.asset('assets/images/mb.png'),
                    iconSize: 75,
                    onPressed: () async {
                      ws.post(Multibanco.postRequest(
                          orderId: 'Arena${Userr().phoneNbr}',
                          amount: _check.price.toString(),
                          description: 'Reserva de ${Userr().name} ${Userr().surname}',
                          clientName: Userr().name,
                          clientEmail: Userr().email,
                          clientUsername: Userr().email,
                          clientPhone: Userr().phoneNbr))
                          .then((value) {
                            if(value.Status.toString() == '0'){
                              _showMb(
                                  reference: value.Reference,
                                entity: value.Entity,
                                amount: value.Amount,
                                expiryDate: value.ExpiryDate,
                                error: ''
                              );
                            }else{
                              _showMb(
                                  reference: '',
                                  entity: '',
                                  amount: '',
                                  expiryDate: '',
                                  error: value.Message
                              );
                            }

                      });
                    },
                  ),
                ),
                Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                    icon: Image.asset('assets/images/Logo_MBWay.png'),
                    iconSize: 75,
                    onPressed: () {
                        Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) {
                        return MbWayPayment();
                      }));
                    },
                  ),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }

  Future<http.Response> fetchAlbum() {
    return http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));
  }

  void payWithMBWay() {
    Uri uri = Uri.parse('/ifthenpaymbw.asmx/SetPedidoJSON HTTP/1.1');
    //'https://us-central1-corkpadel-arena-eb47b.cloudfunctions.net/corkArenas?chave=[CHAVE_ANTI_PHISHING]&referencia=[REFERENCIA]&idpedido=[ID_TRANSACAO]&valor=[VALOR]&datahorapag=[DATA_HORA_PAGAMENTO]&estado=[ESTADO]';
    http.post(uri, body: json.encode({}));
  }
}
