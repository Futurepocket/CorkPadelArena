import 'package:cork_padel_arena/models/ReservationStreamPublisher.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                      'Minhas Reservas',
                      style: TextStyle(
                        fontFamily: 'Roboto Condensed',
                        fontSize: 26,
                        color: Colors.lime,
                      ),
                    ),
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
                  ]),
                ),
                complete
                    ? Text(
                        'Completas',
                        style: TextStyle(
                          fontFamily: 'Roboto Condensed',
                          fontSize: 20,
                          color: Colors.lime,
                        ),
                      )
                    : Text(
                        'Por Completar',
                        style: TextStyle(
                          fontFamily: 'Roboto Condensed',
                          fontSize: 20,
                          color: Colors.lime,
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
                            if (reservations[i].userEmail != _user.email) {
                              reservations.removeAt(i);
                              i = i;
                              break;
                            }
                            final String when = reservations[i].day +
                                ' ' +
                                reservations[i].hour;
                            final DateTime dbDay = formatter.parse(when);
                            if (complete) {
                              if (reservations[i].completed == false) {
                                reservations.removeAt(i);
                                i = i;
                              } else
                                i++;
                            } else {
                              if (reservations[i].completed == true) {
                                reservations.removeAt(i);
                                i = i;
                              } else
                                i++;
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
    );
  }
}
