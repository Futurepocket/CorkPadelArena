import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/models/ReservationStreamPublisher.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../src/widgets.dart';

class AdminReservations extends StatefulWidget {
  const AdminReservations({Key? key}) : super(key: key);

  @override
  State<AdminReservations> createState() => _AdminReservationsState();
}

class _AdminReservationsState extends State<AdminReservations>with TickerProviderStateMixin{
  checkoutValue _check = checkoutValue();
  late TabController _tabController;
  late int _index;
  late String filter;
  List<dynamic> _payments = [];
  @override
  void initState() {
    _getPayments();
    filter = "a aguardar pagamento";
    _index = 0;
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }
  void _getPayments(){
    _payments.clear();
    FirebaseFirestore.instance
        .collection('MBPayments')
        .get()
        .then((value) {
          value.docs.forEach((element) {
            print(element);
            if(element['confirmado'] == true){
              _payments.add(element);
            }
          });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.reservations),
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
                    switch(index){
                      case 0:
                        filter = 'por completar';
                        break;
                      case 1:
                        filter = 'pago';
                        break;
                    }
                  });
                },
                indicatorColor: Colors.white,
                isScrollable: true,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.awaitingCompletion,),
                  Tab(text: AppLocalizations.of(context)!.paid,),
                ],
              ),
            ),
          ),
          body: Container(
            constraints: const BoxConstraints(minWidth: double.infinity, maxHeight: 680),
            child: SingleChildScrollView(
              child: Container(
                constraints:
                const BoxConstraints(minWidth: double.infinity, maxHeight: 680),
                child: Column(
                  children: [
                    StreamBuilder(
                        stream: ReservationStreamPublisher().getReservationStream(),
                        builder: (context, snapshot) {
                          final tilesList = <Container>[];
                          if (snapshot.hasData) {
                            List reservations = snapshot.data as List<Reservation>;
                            int i = 0;
                            do {
                              if (reservations.isNotEmpty) {
                                if (reservations[i].state != filter) {
                                  reservations.removeAt(i);
                                }
                                else{
                                  i++;
                                }
                              }
                            } while (i < reservations.length);
                            try {
                              tilesList.addAll(reservations.map((nextReservation) {
                                final DateTime today = DateTime.now();
                                final formatter = DateFormat('dd/MM/yyyy HH:mm');
                                final String whenStarts = nextReservation.day + ' ' + nextReservation.hour;
                                final starts = formatter.parse(whenStarts);
                                return Container(
                                  decoration: BoxDecoration(
                                      color:
                                      today.isAfter(starts)? Color.fromRGBO(255, 0, 0, 0.15)
                                          :Colors.white),
                                  child: ListTile(
                                      leading: Icon(Icons.lock_clock),
                                      title: Text(nextReservation.userEmail),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                  Text('Das ' +
                                  nextReservation.hour +
                                  ' as ' +
                                  nextReservation.duration),
                                          Text('Dia ' + nextReservation.day),
                                        ],
                                      ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _deleting(context, nextReservation.id, nextReservation.price);
                                      },
                                    ),),
                                );
                              }));
                            } catch (e) {
                              return Text('Ainda nao existem reservas');
                            }
                          }
                          // }
                          if (tilesList.isNotEmpty) {
                            return Expanded(
                              child: ListView(
                                children: tilesList,
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text('Ainda nao existem reservas'),
                          );
                        }),
                  ],
                ),
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

