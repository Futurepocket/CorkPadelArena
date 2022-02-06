import 'package:cork_padel_arena/models/ReservationStreamPublisher.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminReservations extends StatefulWidget {
  const AdminReservations({Key? key}) : super(key: key);

  @override
  State<AdminReservations> createState() => _AdminReservationsState();
}

class _AdminReservationsState extends State<AdminReservations>with TickerProviderStateMixin{
  late TabController _tabController;
  late int _index;
  late String filter;

  @override
  void initState() {
    filter = "a aguardar pagamento";
    _index = 0;
    _tabController = new TabController(length: 3, vsync: this);
    super.initState();
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

                  });
                },
                indicatorColor: Colors.white,
                isScrollable: true,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.pendingPayment,),
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
                    Container(
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 80.0,
                            height: 100.0,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.reservations,
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            fontSize: 26,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                          ],
                        ),
                      ]),
                    ),
                    Text(
                      'Completas',
                      style: TextStyle(
                        fontFamily: 'Roboto Condensed',
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    StreamBuilder(
                        stream: ReservationStreamPublisher().getReservationStream(),
                        builder: (context, snapshot) {
                          final tilesList = <ListTile>[];
                          final DateTime today = DateTime.now();
                          final formatter = DateFormat('dd/MM/yyyy hh:mm');
                          if (snapshot.hasData) {
                            List reservations = snapshot.data as List<Reservation>;
                            int i = 0;
                            do {
                              if (reservations.isNotEmpty) {
                                if (reservations[i].state != filter) {
                                  reservations.removeAt(i);
                                  i = i;
                                  break;
                                }
                              }
                            } while (i < reservations.length);
                            try {
                              tilesList.addAll(reservations.map((nextReservation) {
                                return ListTile(
                                    leading: Icon(Icons.lock_clock),
                                    title: Text('Das ' +
                                        nextReservation.hour +
                                        ' as ' +
                                        nextReservation.duration),
                                    subtitle: Text('Dia ' + nextReservation.day));
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
                          return Text('Ainda nao existem reservas');
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
}
