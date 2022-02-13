import 'package:cork_padel_arena/models/ReservationStreamPublisher.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyReservations extends StatefulWidget {
  const MyReservations({Key? key}) : super(key: key);

  @override
  State<MyReservations> createState() => _MyReservationsState();
}

class _MyReservationsState extends State<MyReservations> {
  bool complete = true;
  Userr _user = Userr();
@override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text("Minhas Reservas"),
          backgroundColor: Theme.of(context).primaryColor),
      body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left:20.0, top: 40),
            height: MediaQuery.of(context).size.height*0.85,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                        Text(
                          AppLocalizations.of(context)!.reservations,
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            fontSize: 16,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text(
                            AppLocalizations.of(context)!.myReservations,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 150,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor,
                              onPrimary: Colors.white,
                            ),
                            child: Text(
                              "Completas",
                              style: TextStyle(fontSize: 15),
                            ),
                            onPressed: () {
                              setState(() {
                                complete = true;
                              });
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
                              "Por Completar",
                              style: TextStyle(fontSize: 15),
                            ),
                            onPressed: () {
                              setState(() {
                                complete = false;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                complete
                    ? Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Text(
                          'Completas',
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                    )
                    : Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Text(
                          'Por Completar',
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                    ),
                Container(
                  height: MediaQuery.of(context).size.height*0.55,
                  child: StreamBuilder(
                            stream: ReservationStreamPublisher().getReservationStream(),
                            builder: (context, snapshot) {
                              final tilesList = <ListTile>[];
                              if (snapshot.hasData) {
                                List reservations = snapshot.data as List<Reservation>;
                                int i = 0;
                                do {
                                  if (reservations.isNotEmpty) {
                                    if (reservations[i].userEmail != _user.email) {
                                      reservations.removeAt(i);
                                      i -= 1;
                                    }
                                    if (complete) {
                                      if (reservations[i].completed == false) {
                                        reservations.removeAt(i);
                                        i -= 1;
                                      }
                                    } else {
                                      if (reservations[i].completed == true) {
                                        reservations.removeAt(i);
                                        i -= 1;
                                      }
                                    }
                                  }
                                  i++;
                                } while (i < reservations.length-1);
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
                            }
                            ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
