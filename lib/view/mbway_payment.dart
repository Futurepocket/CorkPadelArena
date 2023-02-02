import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cork_padel_arena/apis/mbway.dart';
import 'package:cork_padel_arena/apis/webservice.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/payment.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/color_loader.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'dash.dart';

class MbWayPayment extends StatefulWidget {
  const MbWayPayment({Key? key}) : super(key: key);

  @override
  _MbWayPaymentState createState() => _MbWayPaymentState();
}

class _MbWayPaymentState extends State<MbWayPayment> {
  final tlmController = TextEditingController();
  final emailController = TextEditingController();
  String? paymentTlm;
  String? paymentEmail;
  final _form = GlobalKey<FormState>();
  var ws = Webservice();
  bool _showLoading = true;
  String _resultText = "";
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool _isAproved = false;
  String? DataHoraPedidoRegistado;
  String? MsgDescricao;
  String? DataHoraPedidoAtualizado;
  String? idPedido;
  String? referencia;
  String? price;


  @override
  void initState() {
    emailController.text = Userr().email;
    price = checkoutValue().price.toString();
    super.initState();
  }

  String emailDetails = '';

  generateEmailDetails() {
    reservationsToCheckOut.forEach((element) {
      emailDetails +=
      '<p>Dia: ${element.day}, das ${element.hour} às ${element.duration}.</p>';
    });
  }

  void _generateReference() {
    referencia = 'CKA${DateFormat('ddMMyyHHmmss').format(DateTime.now())}';
  }

  _sendClientEmail() async {
    await(firestore.collection("reservationEmails").add({
      'to': emailController.text,
      'message': {
        'subject': "Reserva Confirmada",
        'html': '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        
        <p>Olá, ${Userr().name},</p>
        <p>Obrigado pela sua reserva.</p>
        <p>Detalhes:</p>
        <p>$emailDetails</p>
       <p></p>
       <p>Valor: € $price</p>
       <p>Obrigado,</p>
       <p></p>
       A sua equipa Cork Padel Arena
        
        </html>''',
      },
    },)
        .then((value) => print("email queued"),
    )
    );
    print('Email done');
  }

  _sendCompanyEmail() async {
    await(firestore.collection("reservationEmails").add({
      'to': 'corkpadel@corkpadel.com',
      'bcc': 'david@corkpadel.com',
      'message': {
        'subject': "Nova reserva de ${Userr().name} ${Userr()
            .surname} na Arena",
        'html': '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        
        <p>Reserva de ${Userr().name} ${Userr().surname},</p>
        <p>Email: ${emailController.text} Tlm: ${tlmController.text},</p>
        <p>NIF: ${Userr().nif}</p>
        <p>Morada: ${Userr().address}, ${Userr().postCode}, ${Userr().city}</p>
        <p></p>
        <p>Detalhes:</p>
        <p>$emailDetails</p>
       <p></p>
       <p>Valor: € $price</p> 
       <p></p>
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

  @override
  void dispose() {
    super.dispose();
    tlmController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    price = checkoutValue().price.toString();
    Future<void> _savePayment() async {
      CollectionReference payments = FirebaseFirestore.instance.collection(
          'MBWayPayments');
      String idd = 'Arena$paymentTlm' +
          DateFormat('ddMMyyyy HH:mm').format(DateTime.now());
      /////////////////////SAVING PAYMENT////////////////////////////////////
      Payment payment = Payment(
          IdPedido: idPedido!,
          DataHoraPedidoRegistado: DateFormat('ddMMyyyy HH:mm').format(
              DateTime.now()),
          EmailCliente: paymentEmail!,
          Referencia: referencia!,
          tlmCliente: paymentTlm!,
          amount: price!
      );
      await payments.doc(idd).set({
        'IdPedido': payment.IdPedido,
        'DataHoraPedidoRegistado': payment.DataHoraPedidoRegistado,
        'EmailCliente': payment.EmailCliente,
        'Referencia': payment.Referencia,
        'tlmCliente': payment.tlmCliente,
        'amount': payment.amount,
      }).then((value) {
        Navigator.of(context).pop();
        checkoutValue().reservations = 0;
        checkoutValue().price = 0;
        setState(() {
          price = '0';
        });
        reservationsToCheckOut.clear();
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
          return const Dash();
        }));
        ScaffoldMessenger.of(context).showSnackBar(
            newSnackBar(context, const Text('Reservas Efetuados')));
      }).catchError((onError) => print("Failed to save payment: $onError"));
    }
    Future <void> _saveAll() async {
      final reservations = database.child('reservations');
      generateEmailDetails();
      for (var element in reservationsToCheckOut) {
        try {
          await reservations.child(element.id).update({
            'state': 'pago',
            'completed': true
          });
        } catch (e) {
          print('There is an error!');
        }
      }
    }
    void itIsDone() async{ //COLOCAR NA CLOUD FUNCTION
      await Future.delayed(
          const Duration(milliseconds: 2000), () async{
        await _saveAll().then((value) async{
          await _sendCompanyEmail();
          await _sendClientEmail();
          await _savePayment();
        }).then((value) => Navigator.of(context).pop());
      });
    }
    Timer? timer;
    void awaitingConfirmation(BuildContext context) async {
      generateEmailDetails();
      final functions = FirebaseFunctions.instance;
      _showLoading = true;
      _isAproved = false;
      bool confirmed = false;
      showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                timer?.cancel();
                timer = Timer.periodic(Duration(seconds: 2), (Timer t) async {
                  if (!confirmed) {

                     Map emailToCloud = {
                      'to': 'corkpadel@corkpadel.com',
                      'bcc': 'david@corkpadel.com',
                      'message': {
                        'subject': "Nova reserva de ${Userr().name} ${Userr()
                            .surname} na Arena",
                        'html': '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
                        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
                        
                        <p>Reserva de ${Userr().name} ${Userr().surname},</p>
                        <p>Email: ${emailController.text} Tlm: ${tlmController.text},</p>
                        <p>NIF: ${Userr().nif}</p>
                        <p>Morada: ${Userr().address}, ${Userr().postCode}, ${Userr().city}</p>
                        <p></p>
                        <p>Detalhes:</p>
                        <p>$emailDetails</p>
                       <p></p>
                       <p>Valor: € $price</p> 
                       <p></p>
                       <p>Obrigado,</p>
                       <p>A sua equipa Cork Padel Arena</p>
                        
                        </html>''',
                      },
                    };

                    Map clientEmailToCloud = {
                      'to': emailController.text,
                      'message': {
                        'subject': "Reserva Confirmada",
                        'html': '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
                        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
                        
                        <p>Olá, ${Userr().name},</p>
                        <p>Obrigado pela sua reserva.</p>
                        <p>Detalhes:</p>
                        <p>$emailDetails</p>
                       <p></p>
                       <p>Valor: € $price</p>
                       <p>Obrigado,</p>
                       <p></p>
                       A sua equipa Cork Padel Arena
                        
                        </html>''',
                        },
                      };

                     String idd = 'Arena$paymentTlm' + DateFormat('ddMMyyyy HH:mm').format(DateTime.now());
                     /////////////////////SAVING PAYMENT////////////////////////////////////
                     Map payment = {
                       "IdPedido": idPedido!,
                       "DataHoraPedidoRegistado": DateFormat('ddMMyyyy HH:mm')
                           .format(
                           DateTime.now()),
                       "EmailCliente": paymentEmail!,
                       "Referencia": referencia!,
                       "tlmCliente": paymentTlm!,
                       "amount": price!
                     };
                     List<dynamic> list = reservationsToCheckOut.map((e) => Reservation.toMap(e)).toList();
                     try {
                       final result = await functions.httpsCallable(
                           "checkPayment").call({
                         "reservationsToCheckOut": list,
                         "emailToCloud": emailToCloud,
                         "clientEmailToCloud": clientEmailToCloud,
                         "idPedido": idPedido,
                         "payment": payment,
                         "idd": idd
                       });
                       if(result.data == 0) {
                         setState((){
                           confirmed = true;
                         });
                         print(result);
                       } else if(result.data == 1){
                         setState(() {
                           _showLoading = false;
                           _isAproved = false;
                           _resultText = 'Por favor confirme o pagamento na app.';
                         });
                         print("Não resultou: ${result.data}");
                       }
                       } on FirebaseFunctionsException catch (error){
                       print(error.code);
                       print(error.details);
                       print(error.message);
                     }
                  }else{
                    timer!.cancel();
                    setState(() {
                      _showLoading = false;
                      _isAproved = false;
                      _resultText = 'Pagamento confirmado. Receberá confirmação dentro de momentos.';
                    });
                  }
                });
                return AlertDialog(
                  content: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: ListBody(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'A aguardar pagamento',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Text("Não feche a app antes de finalizar o pagamento", style: TextStyle(color: Colors.red),),
                        _showLoading ?
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ColorLoader(),
                        )
                            :
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            _resultText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    _isAproved ?
                    Container(
                    )
                        : OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "CANCELAR",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              }
          );
        },
      );
    }
    void _saveForm(BuildContext context) {
      final isValid = _form.currentState!.validate();
      if (!isValid) {
        return;
      }
      bool requested = false;
      _form.currentState!.save();
      showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                if (!requested) {
                  _generateReference();
                  ws.get(Mbway.getRequest(
                      referencia: referencia!,
                      valor: '1', // price!
                      nrtlm: paymentTlm!,
                      email: paymentEmail!,
                      descricao: 'testdesc')).then((value) async {
                    await Future.delayed(
                        const Duration(milliseconds: 2000), () {});
                    if (value.Estado == "000") {
                      requested = true;
                      setState(() {
                        _showLoading = false;
                        _isAproved = true;
                        _resultText =
                        "Por favor aprove o pagamento na sua app MBWay";
                        idPedido = value.IdPedido;
                      });
                      Navigator.of(context).pop();
                      awaitingConfirmation(context);
                    }
                    else {
                      setState(() {
                        _showLoading = false;
                        _isAproved = false;
                        _resultText = 'Estado: ${value.Estado}\n'
                            '${value.MsgDescricao}';
                      });
                    }
                  });
                }
                return AlertDialog(
                  content: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: ListBody(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'A processar pagamento',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        _showLoading ?
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ColorLoader(),
                        )
                            :
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            _resultText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    _isAproved ?
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancelar",
                      ),
                    )
                        : Container(),
                    _isAproved ?
                    Container(
                    )
                        : _showLoading == false ? OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(color: Colors.white),
                      ),
                    ) : Container(),
                  ],
                );
              }
          );
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: const Text("Pagamento"),
          backgroundColor: Theme
              .of(context)
              .primaryColor),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(35.0),
          child: Form(
            key: _form,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Image.asset(
                      'assets/images/Logo_MBWay.png',
                      width: 80.0,
                      height: 100.0,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Valor total: € $price.00',
                      style: const TextStyle(
                        fontFamily: 'Roboto Condensed',
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Pagamento',
                      style: TextStyle(
                        fontFamily: 'Roboto Condensed',
                        fontSize: 26,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: tlmController,
                      textInputAction: TextInputAction.next,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              width: 1.5),
                        ),
                        labelText: 'Numero de Telemovel',
                        // errorText: 'Error Text',
                      ),
                      onSaved: (value) {
                        paymentTlm = value.toString();
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.required;
                        }
                        return null;
                      },
                    ),
                  ),

//---------------------------------------//EMAIL-------------------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme
                                  .of(context)
                                  .primaryColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme
                                  .of(context)
                                  .primaryColor, width: 1.5),
                        ),
                        labelText: "Email",
                        // errorText: 'Error Text',
                      ),
                      onSaved: (value) {
                        paymentEmail = value.toString();
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.required;
                        }
                        return null;
                      },
                    ),
                  ),
//---------------------------------------//BOTAO-------------------------------------------------------------
                  Container(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme
                            .of(context)
                            .primaryColor,
                        onPrimary: Colors.white,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.submit,
                        style: const TextStyle(fontSize: 15),
                      ),
                      onPressed: () {
                        final isValid = _form.currentState!.validate();
                        if (isValid) {
                          _saveForm(context);
                        }
                      },
                    ),
                  ),
                ]
            ),
          ),
        ),


      ),
    );
  }
}
