import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late Map<String, dynamic> _thisPayment;
  @override
  void initState() {
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
    final reservations = database.child('reservations');
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
            pagamentos.doc(_thisPayment['reservations']).set(_reservations);
            _reservations.forEach((element) async{
              try {
                await reservations.child(element['id']).update({
                  'state': element['state'],
                'completed': element['completed']}).then((value) {
                });
              } catch (e) {
                print(e);
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
                newSnackBar(context, Text(AppLocalizations.of(context)!.paymentValidated)));
            generateEmailDetails();
            _sendClientEmail(
                email: _reservations[0]['client_email'],
                name: _thisPayment['clientName']);
            Navigator.of(context).pop();
          }
    });
  }
  String emailDetails = '';
  generateEmailDetails(){
    _reservations.forEach((element) {
      emailDetails += '<p>Dia: ${element['day']}, das ${element['hour']} às ${element['duration']}.</p>';
    });
  }
  _sendClientEmail({
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Align(
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
              Text(
                'Pagamentos',
                style: TextStyle(
                  fontFamily: 'Roboto Condensed',
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:8.0),
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
                EdgeInsets.only(top: 20, right: 15, bottom: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Card(elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                      width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(top:5, left: 10),
                        child: FutureBuilder<DocumentSnapshot>(
                          future: pagamentos.doc(widget.paymentID).get(),
                          builder:
                              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

                            if (snapshot.hasError) {
                              return Text("Something went wrong");
                            }

                            if (snapshot.hasData && !snapshot.data!.exists) {
                              return Text("Document does not exist");
                            }

                            if (snapshot.connectionState == ConnectionState.done) {
                              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                              _thisPayment = data;
                                _reservations = data['reservations'];
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
                                        Text("Nome do Cliente: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('${data['clientName']}')
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                          Text("Email do Cliente: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('${data['reservations'][0]['client_email']}')
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Text("ID de Pagamento: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("${data['OrderId']}"),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Text("Data do Pedido: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("${data['data']}"),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Text("Valor: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("€ ${data['Amount']}"),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Text("Confirmado: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("${data['confirmado']}"),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top:8.0),
                                    child: Text("Reservas: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Expanded(

                                      child: _buildReservationsList()
                                  ),
                                ],
                                )
                              );
                            }
                            return Text("loading");
                          },
                        )
                      ),
                    ],
                  ),
                ),
              ),
              _thisPayment['confirmado'] == false?
              Align(
                alignment: Alignment.center,
                child:
                    Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          onPrimary: Colors.white,
                        ),
                        child: Text(
                          "CONFIRMAR PAGAMENTO",
                          style: TextStyle(fontSize: 15,),
                        ),
                        onPressed: () {
                         _confirmPayment();
                        },
                      ),
                    ),
              ) :
                  Container()
            ],
          ),
        ),
      ),

    );
  }
}
