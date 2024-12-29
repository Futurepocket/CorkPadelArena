import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cork_padel_arena/apis/mbway.dart';
import 'package:cork_padel_arena/apis/webservice.dart';
import 'package:cork_padel_arena/main.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/payment.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/src/constants.dart';
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
  bool shallIPay = true;
  Map<String, dynamic> companyEmailToCloud = {};
  Map<String, dynamic> clientEmailToCloud = {};

  // FirebaseFirestore databasePayments = FirebaseFirestore.instance.collection('MBWayPayments').id("");

  @override
  void initState() {
    emailController.text = Userr().email;
    price = checkoutValue().price.toString();
    super.initState();
  }

  String emailDetails = '';

  generateEmailDetails() {
    for (var element in reservationsToCheckOut.value) {
      emailDetails +=
          '<p>Dia: ${element.day}, das ${element.hour} às ${element.duration}.</p>';
    }
  }

  void _generateReference() {
    referencia = 'CKA${DateFormat('ddMMyyHHmmss').format(DateTime.now())}';
  }

  _createClientEmail() {
    clientEmailToCloud = {
      'to': emailController.text,
      'message': {
        'subject': "Reserva Confirmada",
        'html':
            '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
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
  }

  _createCompanyEmail() {
    companyEmailToCloud = {
      'to': 'corkpadel@corkpadel.com',
      'bcc': 'david@corkpadel.com; corkpadel@gmail.com',
      'message': {
        'subject':
            "Nova reserva de ${Userr().name} ${Userr().surname} na Arena",
        'html':
            '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
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
      }
    };
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
    void clearAll() {
      checkoutValue().reservations = 0;
      checkoutValue().price = 0;
      setState(() {
        price = '0';
      });
      reservationsToCheckOut.value.clear();
      // Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) {
        return const Dash();
      }), ModalRoute.withName("/login"));
      ScaffoldMessenger.of(context)
          .showSnackBar(newSnackBar(context, const Text('Reservas Efetuados')));
    }

    void itIsDone() async {
      //COLOCAR NA CLOUD FUNCTION
      await Future.delayed(const Duration(seconds: 5), () {
        clearAll();
      });
    }

    Timer? timer;

    void awaitingConfirmation() async {
      String idd =
          'Arena$paymentTlm${DateFormat('ddMMyyyy HH:mm').format(DateTime.now())}';
      Map<String, dynamic> payment = {
        "IdPedido": idPedido!,
        "DataHoraPedidoRegistado":
            DateFormat('ddMMyyyy HH:mm').format(DateTime.now()),
        "EmailCliente": paymentEmail!,
        "Referencia": referencia!,
        "tlmCliente": paymentTlm!,
        "amount": price!
      };
      generateEmailDetails();
      _createCompanyEmail();
      _createClientEmail();
      final functions = FirebaseFunctions.instance;
      _showLoading = true;
      _isAproved = false;
      bool confirmed = false;
      var collectionRef =
      FirebaseFirestore.instance.collection('MBWayPayments');
      var doc = await collectionRef.doc(idd).get();
      if (doc.exists) {
        setState(() {
          confirmed = true;
        });
      } else {
        // setState(() {
        //   _showLoading = true;
        //   _isAproved = false;
          _resultText =
          'Por favor confirme o pagamento na app MBWay.';
        // });
        /////////////////////SAVING PAYMENT////////////////////////////////////
        List<dynamic> list = reservationsToCheckOut.value
            .map((e) => Reservation.toMap(e))
            .toList();
        try {
          functions.httpsCallable("checkPayment", options: HttpsCallableOptions(timeout: const Duration(minutes: 6))).call({
            "reservationsToCheckOut": list,
            "companyEmailToCloud": companyEmailToCloud,
            "clientEmailToCloud": clientEmailToCloud,
            "idPedido": idPedido,
            "payment": payment,
            "idd": idd
          }).then((value) {
           if(value.data != null){
             if(value.data == 0){
               itIsDone();
             }
           }
          }
            ,);
          // print(result);
        } on FirebaseFunctionsException catch (error) {
          print(error.code);
          print(error.details);
          print(error.message);
        }
      }

      showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {

              return AlertDialog(
                content: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: ListBody(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'A aguardar pagamento MBWay',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        _resultText,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                      _showLoading
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ColorLoader(),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(
                                _resultText,
                                style: const TextStyle(fontSize: 16),
                              ),
                            )
                    ],
                  ),
                ),
              );

          });

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
              ws
                  .get(Mbway.getRequest(
                      referencia: referencia!,
                      valor: price!,
                      nrtlm: paymentTlm!,
                      email: paymentEmail!,
                      descricao: 'testdesc'))
                  .then((value) async {
                await Future.delayed(const Duration(milliseconds: 2000), () {});
                if (value.Estado == "000") {
                  requested = true;
                  setState(() {
                    _showLoading = false;
                    _isAproved = true;
                    _resultText =
                        "Por favor aprove o pagamento na sua app MBWay";
                    idPedido = value.IdPedido;
                  });
                  
                  awaitingConfirmation();
                } else {
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
                    _showLoading
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ColorLoader(),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Text(
                              _resultText,
                              style: const TextStyle(fontSize: 16),
                            ),
                          )
                  ],
                ),
              ),
              actions: <Widget>[
                _isAproved
                    ? Container()
                    : _showLoading == false
                        ? OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "OK",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () {
                              setState(() {
                                shallIPay = false;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "CANCEL",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
              ],
            );
          });
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Pagamento"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(35.0),
          child: Form(
            key: _form,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/Logo_MBWay.png',
                      // width: 80.0,
                      scale: 0.5,
                      // height: 80.0,
                    ),
                  ),
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
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Pagamento',
                  style: TextStyle(
                    fontSize: 26,
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
                  decoration: inputDecor(
                      label: localizations.phone,
                      context: context,
                      prefixIcon: Icons.phone),
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
                  decoration: inputDecor(
                      label: "Email",
                      context: context,
                      prefixIcon: Icons.alternate_email),
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

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.submit,
                  ),
                  onPressed: () {
                    final isValid = _form.currentState!.validate();
                    if (isValid) {
                      _saveForm(context);
                    }
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
