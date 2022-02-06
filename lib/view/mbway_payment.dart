import 'dart:math';

import 'package:cork_padel_arena/apis/mbway.dart';
import 'package:cork_padel_arena/apis/webservice.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/payment.dart';
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
  checkoutValue _check = checkoutValue();
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

  @override
  void initState() {
    emailController.text = Userr().email;
    super.initState();
  }
String emailDetails = '';
  generateEmailDetails(){
    reservationsToCheckOut.forEach((element) {
      emailDetails += '<p>Dia: ${element.day}, das ${element.hour} às ${element.duration}.</p>';
    });
    reservationsToCheckOut.clear();
  }

  void _generateReference(){
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
        Detalhes:\n
        <p>${emailDetails}</p>
       \n
       <p>Valor: € ${_check.price.toString()}</p>
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

  _sendCompanyEmail() async {
    await(firestore.collection("reservationEmails").add({
      'to': 'david.carvalhan@gmail.com', //TODO ADD corkpadel@corkpadel.com
      'message': {
        'subject': "Nova reserva de ${Userr().name} ${Userr().surname} na Arena",
        'html': '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        
        <p>Reserva de ${Userr().name} ${Userr().surname},</p>
        <p>Email: ${tlmController.text} Tlm: ${emailController.text},</p>
        \n
        Detalhes:\n
        <p>${emailDetails}</p>
       \n
       <p>Valor: € ${_check.price.toString()}</p> 
       
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
  Widget build(BuildContext context) {

    _saveAll() async{
      CollectionReference payments = FirebaseFirestore.instance.collection('MBWayPayments');
      String _idd = 'Arena${paymentTlm}' + DateFormat('ddMMyyyy HH:mm').format(DateTime.now());

/////////////////////SAVING PAYMENT////////////////////////////////////
      Payment _payment = Payment(
          IdPedido: idPedido!,
          DataHoraPedidoRegistado: DataHoraPedidoRegistado!,
          MsgDescricao: MsgDescricao!,
          DataHoraPedidoAtualizado: DataHoraPedidoAtualizado!,
          EmailCliente: paymentEmail!,
          Referencia: referencia!,
          tlmCliente: paymentTlm!);
      await payments.doc(_idd).set({
      _payment.toMap()
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
            newSnackBar(context, Text('Reservas Efetuados')));
      }).catchError((onError) => print("Failed to save payment: $onError"));
//////////////////////////SAVING RESERVATION////////////////////////////////////

      final reservations = database.child('reservations');
reservationsToCheckOut.forEach((element) async{
  try {
    await reservations.child(element.id).set({
      'state': 'pago',
      'completed': true,
    });
  } catch (e) {
    print('There is an error!');
  }
  generateEmailDetails();
  _sendClientEmail();
  _sendCompanyEmail();
  reservationsToCheckOut.clear();
  _check.reservations = 0;
  _check.price = 0;
});
    }

    void _saveForm(BuildContext context) {
      final isValid = _form.currentState!.validate();
      if (!isValid) {
        return;
      }
      _form.currentState!.save();
      showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              _generateReference();
              ws.get(Mbway.getRequest(
                  referencia: referencia!,
                  valor: '0,01',
                  nrtlm: paymentTlm!,
                  email: paymentEmail!,
                  descricao: 'testdesc')).then((value) async {
                await Future.delayed(const Duration(milliseconds: 2000), () {});
                if(value.Estado == "000"){
                  setState(() {
                    _showLoading = false;
                    _isAproved = true;
                    _resultText = "Por favor aprove o pagamento na sua app MBWay";
                    idPedido = value.IdPedido;
                  });
                }
                else{
                  setState(() {
                    _showLoading = false;
                    _isAproved = false;
                    _resultText = 'Estado: ${value.Estado}\n'
                        '${value.MsgDescricao}';
                  });
                }
              });
              return AlertDialog(
                content: SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: ListBody(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'A processar pagamento',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  _isAproved?
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancelar",
                    ),
                  )
                  :Container(),
                  _isAproved?
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                    onPressed: () {
                      setState(() {
                        _showLoading = true;
                      });
                      ws.get(Mbway.getRequestState(idPagamento: idPedido!))
                          .then((value) async {
                        if(value['Estado'] == "000"){
                          setState(() {
                            _showLoading = false;
                            _resultText = "Pagamento efectuado com sucesso";
                            _isAproved = false;
                            _saveAll();
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_){
                              return Dash();
                            }));
                          });
                          await Future.delayed(const Duration(milliseconds: 2000), () {});
                        }else{
                          setState(() {
                            _showLoading = false;
                            _isAproved = false;
                            _resultText = value['MsgDescricao'];
                          });
                        }
                      });
                    },
                    child: Text(
                      "APROVADO",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                  : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "OK",
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



    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text("Pagamento"),
          backgroundColor: Theme.of(context).primaryColor),
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
                  'Valor total: €' + _check.price.toString(),
                  style: TextStyle(
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
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: tlmController,
                      textInputAction: TextInputAction.next,
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: false),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
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
                      contentPadding: EdgeInsets.all(10),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 1.5),
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
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.submit,
                      style: TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      //_saveForm(context);
                      final isValid = _form.currentState!.validate();
                      if (isValid) {
                        _saveForm(context);
                      }
                    },
                  ),
                ),
              Container(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.white,
                  ),
                  child: Text(
                    'TEST EMAIL',
                    style: TextStyle(fontSize: 15),
                  ),
                  onPressed: () {

                    generateEmailDetails();
                   _sendClientEmail();
                   _sendCompanyEmail();
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
