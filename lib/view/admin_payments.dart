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

  List<dynamic> _payments = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> dbPayments = FirebaseFirestore.instance.collection('MBWayPayments')
        .snapshots(includeMetadataChanges: true);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.payments),
          ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              Container(
                // width: MediaQuery.of(context).size.width *0.9,
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
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.payments_outlined),
                            title: Text(data['Referencia']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${data['EmailCliente']}'),
                                Text('€ ${data['amount']}'),
                              ],
                            ),

                          ),
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
    );
  }
}

