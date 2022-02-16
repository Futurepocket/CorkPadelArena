import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/apis/multibanco.dart';
import 'package:cork_padel_arena/apis/webservice.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/view/dash.dart';
import 'package:cork_padel_arena/view/mbway_payment.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:intl/intl.dart';

import '../models/reservation.dart';

class Checkout extends StatefulWidget {
  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  String? referencia;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var ws = Webservice();
  String? _price;
  void _generateReference(){
    referencia = 'CKA${DateFormat('ddMMyyHHmmss').format(DateTime.now())}';
  }
@override
  void initState() {
   _price = checkoutValue().price.toString();
    print(_price);
    super.initState();
  }

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
                          style: const TextStyle(fontSize: 18),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'Vai receber um email com estes detalhes',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                      Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(builder: (context){
                            return Dash();
                      }));
                    },
                    child: Text(
                      "OK",
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

  String emailDetails = '';
  generateEmailDetails(list){
    list.forEach((element) {
      emailDetails += '<p>Dia: ${element['day']}, das ${element['hour']} às ${element['duration']}.</p>';
    });
  }
  _sendClientEmail({
    required String email,
    required String name,
    required String referencia,
    required String entidade,
    required String valor,
  }) async {
    await(firestore.collection("reservationEmails").add({
      'to': email,
      'message': {
        'subject': "Reserva Pendente",
        'html': '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        
        <p>Olá, $name,</p>
        <p>A sua reserva foi está pendente.</p>
        <p>Por favor efetue pagamento em 24 horas.</p>
        Detalhes:\n
        ${emailDetails}
       
       <p>Detalhes de Pagamento:</p>
       <p>Entidade: $entidade</p>
       <p>Referencia: $referencia</p>
       <p>Valor: € $valor.00</p>
       <p>Obrigado,</p>

       A sua equipa Cork Padel Arena
        
        </html>''',
      },
    },)
        .then((value) => print("email queued"),
    )
    );
    print('Email done');
  }

  _sendCompanyEmail(orderId) async {
    await(firestore.collection("reservationEmails").add({
      'to': 'david.carvalhan@gmail.com', //TODO ADD corkpadel@corkpadel.com
      'message': {
        'subject': "Nova reserva PENDENTE de ${Userr().name} ${Userr().surname} na Arena",
        'html': '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

        <p>Reserva de ${Userr().name} ${Userr().surname},</p>
        <p>Email: ${Userr().email} Tlm: ${Userr().phoneNbr},</p>
        <p></p>
        <p>Detalhes:</p>
        <p>ID do Pagamento:$orderId</p>
        <p>${emailDetails}</p>
       <p></p>
       <p>Valor: € ${_price}</p>
       <p></p>
       <p>PRECISA SER CONFIRMADA NA SECÇÃO DE PAGAMENTOS NA DASHBOARD DE ADMINISTRADOR DA APP</p>
       <p>Obrigado,</p>
       <p>A sua equipa Cork Padel Arena</p>

        </html>''',
      },
    },)
        .then((value) => print("email queued"),
    )
    );
    print('Email done');
  }
  DatabaseReference database = FirebaseDatabase.instance.ref();

  CollectionReference mbPayments = FirebaseFirestore.instance.collection('MBPayments');
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
                'Valor total: € ${_price!}.00',
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
                      _generateReference();
                      ws.post(Multibanco.postRequest(
                          orderId: referencia!,
                          amount: _price!,
                          description: 'Reserva de ${Userr().name} ${Userr().surname}',
                          clientName: Userr().name,
                          clientEmail: Userr().email,
                          clientUsername: Userr().email,
                          clientPhone: Userr().phoneNbr))
                          .then((value) async{
                            if(value.Status.toString() == '0'){
                              _showMb(
                                  reference: value.Reference,
                                entity: value.Entity,
                                amount: value.Amount,
                                expiryDate: value.ExpiryDate,
                                error: ''
                              );
                              List <dynamic>resToSave = [];
                              final reservations = database.child('reservations');
                              reservationsToCheckOut.forEach((element) async{
                                  element.state = 'a aguardar pagamento';
                                resToSave.add(Reservation.toMap(element));
                              });
                              resToSave.forEach((element) async{
                                try {
                                  await reservations.child(element['id']).update({'state': element['state']}).then((value) {
                                  });
                                } catch (e) {
                                  print(e);
                                }
                              });
                              mbPayments.doc(referencia!).set({
                                "confirmado": false,
                                "clientName": '${Userr().name} ${Userr().surname}',
                                "Amount": value.Amount,
                                "OrderId": value.OrderId,
                                "RequestId": value.RequestId,
                                "data": DateFormat('dd/MM/yy HH:mm').format(DateTime.now()),
                                "reservations": resToSave,
                              }).then((_) {
                                generateEmailDetails(resToSave);
                                _sendClientEmail(
                                    name: '${Userr().name} ${Userr().surname}',
                                    email: Userr().email,
                                    referencia: value.Reference,
                                    entidade: value.Entity,
                                    valor: value.Amount,
                                    );
                                _sendCompanyEmail(value.OrderId);
                                reservationsToCheckOut.clear();
                                checkoutValue().price = 0;
                              });


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
