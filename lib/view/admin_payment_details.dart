import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/constants/constants.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PaymentDetails extends StatefulWidget {
  @override
  _PaymentDetailsState createState() => _PaymentDetailsState();
  final String paymentID;
  PaymentDetails(this.paymentID);
}

class _PaymentDetailsState extends State<PaymentDetails> {
  CollectionReference pagamentos = FirebaseFirestore.instance.collection('MBPayments');
  DatabaseReference database = FirebaseDatabase.instance.ref();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<dynamic> _reservations = [];
  Map<String, dynamic> _thisPayment = {};
  bool isConfirmed = false;
  bool isExpired = false;
  String _thisEmail = '';

  _checkIt(){
    final DateTime today = DateTime.now();
    final formatter = DateFormat('dd/MM/yy HH:mm');
    pagamentos.doc(widget.paymentID).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          isConfirmed = documentSnapshot.get('confirmado');
          final DateTime made = formatter.parse(documentSnapshot.get('data'));
          if(today.isAfter(made.add(const Duration(hours: 24)))){
            isExpired = true;
          }else{
            isExpired = false;
          }
        });
      }
    });
  }

  @override
  void initState() {
    _checkIt();
    super.initState();
  }
  settingState(){
    setState(() {

    });
  }
  Widget _buildReservationsList(){
    return ListView.builder(
        itemCount: _reservations.length,
        itemBuilder: _buildReservationsRow);
  }
  ListTile _buildReservationsRow(BuildContext context, int index,){
    return ListTile(
      leading: const Icon(Icons.lock_clock),
      title: Text('Dia: ${_reservations[index]['day']}'),
      subtitle: Text('Das: ${_reservations[index]['hour']} as ${_reservations[index]['duration']}'),
    );
  }

  void _confirmPayment() {
    final reservations = database.child(reservationDatabase);
    simpleConfirmationDialogue(context: context,
        warning: AppLocalizations.of(context)!.validatePayment,)
        .then((value) {
          if(value == true){
            pagamentos.doc(_thisPayment['OrderId']).update({
              "confirmado": true,
            });
            _reservations.forEach((element) {
              element['state'] = 'pago';
              element['completed'] = true;
            });
            pagamentos.doc(_thisPayment['OrderId']).update({'reservations': _reservations});
            _reservations.forEach((element) async{
              try {
                await reservations.child(element['id']).update({
                  'state': element['state'],
                'completed': element['completed']}).then((value) {
                });
              } catch (e) {

              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
                newSnackBar(context, Text(AppLocalizations.of(context)!.paymentValidated)));
            generateEmailDetails();
            _sendClientEmail(
                email: _thisEmail,
                name: _thisPayment['clientName']).then((value){
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
          }
    });
  }
  String emailDetails = '';
  generateEmailDetails(){
    _reservations.forEach((element) {
      emailDetails += '<p>Dia: ${element['day']}, das ${element['hour']} às ${element['duration']}.</p>';
    });
  }
  Future<bool> _sendClientEmail({
    required String email,
  required String name}) async {
    await(firestore.collection("reservationEmails").add({
      'to': email,
      'message': {
        'subject': "Reserva Confirmada",
        'html': '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        
        <p>Olá, $name,</p>
        <p>A sua reserva foi confirmada.</p>
        Detalhes:\n
        ${emailDetails}
       \n
       
       <p>Obrigado,</p>

       A sua equipa Cork Padel Arena
        
        </html>''',
      },
    },)
        .then((value) => print("email queued"),
    )
    );
    print('Email done');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: const Align(
              alignment: Alignment.centerLeft,
              child: Text("Cork Padel Arena")),
          backgroundColor: Theme.of(context).primaryColor),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(left:20.0, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pagamentos',
                style: TextStyle(
                  fontFamily: 'Roboto Condensed',
                  fontSize: 16,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top:8.0),
                child: Text(
                  'Detalhes de Pagamento',
                  style: TextStyle(
                    fontFamily: 'Roboto Condensed',
                    fontSize: 28,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width*0.9,
                height: 20,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.grey.shade600,
                            width: 2
                        ))),),
              Container(
                padding:
                const EdgeInsets.only(top: 20, right: 15, bottom: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Card(elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                      width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(top:5, left: 10),
                        child: FutureBuilder<DocumentSnapshot>(
                          future: pagamentos.doc(widget.paymentID).get(),
                          builder:
                              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

                            if (snapshot.hasError) {
                              return const Text("Something went wrong");
                            }

                            if (snapshot.hasData && !snapshot.data!.exists) {
                              return const Text("Document does not exist");
                            }

                            if (snapshot.connectionState == ConnectionState.done) {
                              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                              _thisPayment = data;
                                _reservations = data['reservations'];
                              _thisEmail = data['reservations'][0]['client_email'];
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height*0.5,
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        const Text("Nome do Cliente: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('${data['clientName']}')
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                          const Text("Email do Cliente: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('${data['reservations'][0]['client_email']}')
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        const Text("ID de Pagamento: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("${data['OrderId']}"),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        const Text("Data do Pedido: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("${data['data']}"),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        const Text("Valor: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("€ ${data['Amount']}"),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        const Text("Confirmado: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("${data['confirmado']}"),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top:8.0),
                                    child: Text("Reservas: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Expanded(
                                      child: _buildReservationsList()
                                  ),
                                ],
                                )
                              );
                            }
                            return const Text("loading");
                          },
                        )
                      ),
                    ],
                  ),
                ),
              ),
              isConfirmed == false?
              isExpired == true?
                  Align(
                      alignment: Alignment.center,
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            'Este pagemento expirou!',
                            style: TextStyle(
                              fontFamily: 'Roboto Condensed',
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        Container(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.onError, backgroundColor: Theme.of(context).colorScheme.error,
                            ),
                            child: const Text(
                              "REMOVER PAGAMENTO",
                              style: TextStyle(fontSize: 15,),
                            ),
                            onPressed: () {
                              pagamentos.doc(widget.paymentID).delete();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],),
                  )
              : Align(
                alignment: Alignment.center,
                child:
                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      "CONFIRMAR PAGAMENTO",
                      style: TextStyle(fontSize: 15,),
                    ),
                    onPressed: () {
                      _confirmPayment();
                    },
                  ),
                ),
              ):Container()
            ],
          ),
        ),
      ),

    );
  }
}
