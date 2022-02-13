import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/utils/color_loader.dart';
import 'package:cork_padel_arena/view/admin_payment_details.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../src/widgets.dart';

class AdminPayments extends StatefulWidget {
  const AdminPayments({Key? key}) : super(key: key);

  @override
  State<AdminPayments> createState() => _AdminPaymentsState();
}

class _AdminPaymentsState extends State<AdminPayments>with TickerProviderStateMixin{

  late TabController _tabController;
  late int _index;
  late bool filter;
  List<dynamic> _payments = [];
  @override
  void initState() {
    filter = false;
    _index = 0;
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> dbPayments = FirebaseFirestore.instance.collection('MBPayments')
        .where('confirmado', isEqualTo: filter).snapshots(includeMetadataChanges: true);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.payments),
          backgroundColor: Theme.of(context).primaryColor),
      body: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 8,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(0.0),
              child: TabBar(
                labelColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1),
                controller: _tabController,
                onTap: (index){
                  setState(() {
                    if(index == 0){
                      filter = false;
                    }else{
                      filter = true;
                    }
                  });
                },
                indicatorColor: Colors.white,
                isScrollable: true,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.pendingPayment,),
                  Tab(text: AppLocalizations.of(context)!.paid,),
                ],
              ),
            ),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width*0.9,
            height: MediaQuery.of(context).size.height*0.9,
            constraints: const BoxConstraints(minWidth: double.infinity, maxHeight: 680),
            child: SingleChildScrollView(
              child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width *0.9,
                      height: MediaQuery.of(context).size.height*0.9,
                      child:
                      Scrollbar(
                      child:
                      StreamBuilder<QuerySnapshot>(
                        stream: dbPayments,
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return ColorLoader();
                          }
                          return snapshot.data!.docs.isNotEmpty?
                          ListView(
                            children: snapshot.data!.docs.map((DocumentSnapshot document) {
                              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                              return ListTile(
                                leading: Icon(Icons.payments_outlined),
                                title: Text(data['OrderId']),
                                subtitle: Text('€ ${data['Amount']}'),
                                onTap: (){
                                  Navigator.of(
                                    context,
                                  ).push(MaterialPageRoute(builder: (_) {
                                    return PaymentDetails(data['OrderId']);
                                  }));
                                },
                              );
                            }).toList(),
                          )
                              :Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text('Sem pagamentos para mostrar'),
                          );
                        },
                      ),
                    ),)
                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _deleting(BuildContext context, String id, String price) {
    final _database =
    FirebaseDatabase.instance.ref().child('reservations').child(id);
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState)
            {
              return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: const TextStyle(fontSize: 24),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.sureToCancelReservation,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  StyledButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.doNotCancel,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    background: Colors.white,
                    border: Theme.of(context).colorScheme.primary,
                  ),
                  StyledButton(
                    onPressed: () {
                      _database.remove();
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.yesCancel,
                      style: const TextStyle(color: Colors.white),
                    ),
                    background: Colors.red,
                    border: Colors.red,
                  ),
                ],
              );
            });
      },
    );
  }
}

