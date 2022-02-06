import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'dash.dart';
import 'editDetails.dart';
import 'myReservations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PaymentDetails extends StatefulWidget {
  @override
  _PaymentDetailsState createState() => _PaymentDetailsState();
  final String paymentID;
  PaymentDetails(this.paymentID);
}

class _PaymentDetailsState extends State<PaymentDetails> {
  checkoutValue _check = checkoutValue();
  @override
  void initState() {
    super.initState();
  }
  settingState(){
    setState(() {

    });
  }
  Userr _userr = Userr();
  static const double _padd = 10.0;

  @override
  Widget build(BuildContext context) {
    CollectionReference pagamento = FirebaseFirestore.instance.collection('MBPayments');
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Align(
              alignment: Alignment.centerLeft,
              child: Text("Cork Padel Arena")),
          backgroundColor: Theme.of(context).primaryColor),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left:20.0, top: 40),
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
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: FutureBuilder<DocumentSnapshot>(
                      future: pagamento.doc(widget.paymentID).get(),
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
                          return Text("Full Name: ${data['full_name']} ${data['last_name']}");
                        }

                        return Text("loading");
                      },
                    )
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 15, right: 20),
                child:
                    Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          onPrimary: Colors.white,
                        ),
                        child: Text(
                          "MINHAS RESERVAS",
                          style: TextStyle(fontSize: 15,),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (_) {
                            return MyReservations();
                          }));
                        },
                      ),
                    ),
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(
          children: [
            FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                showShoppingCart(context).then((value) {
                  settingState();
                });
              },
              child: Icon(Icons.shopping_cart, color: Colors.white,),
            ),

            reservationsToCheckOut.isEmpty?
            Positioned(
                top: 1.0,
                left: 1.0,
                child: Container())
                : Positioned(
              top: 1.0,
              left: 1.0,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(reservationsToCheckOut.length.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),
            )
          ]
      ),
    );
  }
}
