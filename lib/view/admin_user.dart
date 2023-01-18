import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:flutter/material.dart';
import '../models/ReservationStreamPublisher.dart';
import '../models/reservation.dart';
import 'dash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class AdminUser extends StatefulWidget {
  final _user;
  AdminUser(this._user);
  @override
  _AdminUserState createState() => _AdminUserState();
}

class _AdminUserState extends State<AdminUser> {
  var _user;
  @override
  void initState() {
    super.initState();
    _user = widget._user;
  }
  settingState(){
    setState(() {

    });
  }
  static const double _padd = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: const Align(
              alignment: Alignment.centerLeft,
              child: Text("Cork Padel Arena")),
          backgroundColor: Theme.of(context).primaryColor,),
      body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left:20.0, top:8),
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    AppLocalizations.of(context)!.userProfile,
                    style: const TextStyle(
                      fontFamily: 'Roboto Condensed',
                      fontSize: 28,
                    ),
                  ),
                Container(
                  width: MediaQuery.of(context).size.width*0.9,
                  height: 10,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.grey.shade600,
                              width: 2
                          ))),),
                Container(
                  padding:
                  const EdgeInsets.only(top: 10, right: 15, bottom: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Card(elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Nome: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                _user['first_name'] + ' ' + _user['last_name'],
                                style: const TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: _padd),
                            child: Row(children: [
                              const Text(
                                "Email: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                _user['email'],
                                style: const TextStyle(fontSize: 16),
                              )
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: _padd),
                            child: Row(children: [
                              const Text(
                                "Tel: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                _user['phoneNbr'],
                                style: const TextStyle(fontSize: 16),
                              )
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: _padd),
                            child: Row(
                              children: [
                                const Text(
                                  "Morada: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                SizedBox(
                                  width: 220,
                                  child: Text(
                                    _user['address'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: _padd),
                            child: Row(children: [
                              const Text(
                                "Codigo Postal: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                _user['postal_code'],
                                style: const TextStyle(fontSize: 16),
                              )
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: _padd),
                            child: Row(children: [
                              const Text(
                                "Localidade: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                _user['city'],
                                style: const TextStyle(fontSize: 16),
                              )
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: _padd),
                            child: Row(children: [
                              const Text(
                                "NIF: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                _user['nif'],
                                style: const TextStyle(fontSize: 16),
                              )
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${AppLocalizations.of(context)!.userReservations}:',
                    style: const TextStyle(
                      fontFamily: 'Roboto Condensed',
                      fontSize: 20,
                    ),
                  ),
                ),
                Expanded(
                    child: StreamBuilder(
                        stream: ReservationStreamPublisher().getReservationStream(),
                        builder: (context, snapshot) {
                          final tilesList = <Container>[];
                          if (snapshot.hasData) {
                            List reservations = snapshot.data as List<Reservation>;
                            int i = 0;
                            reservations.removeWhere((element) => element.userEmail != _user['email']);
                            try {
                              tilesList.addAll(reservations.map((nextReservation) {
                                final DateTime today = DateTime.now();
                                final formatter = DateFormat('dd/MM/yyyy HH:mm');
                                final String whenStarts = nextReservation.day + ' ' + nextReservation.hour;
                                final starts = formatter.parse(whenStarts);
                                return Container(
                                  decoration: BoxDecoration(
                                      color:
                                      today.isAfter(starts)? const Color.fromRGBO(255, 0, 0, 0.15)
                                          :Colors.white),
                                  child: ListTile(
                                      leading: const Icon(Icons.lock_clock),
                                      title: Text('Das ' +
                                          nextReservation.hour +
                                          ' as ' +
                                          nextReservation.duration),
                                      subtitle: Text('Dia ' + nextReservation.day)),
                                );
                              }));
                            } catch (e) {
                              return const Text('Ainda nao existem reservas');
                            }
                          }
                          // }
                          if (tilesList.isNotEmpty) {
                            return ListView(
                              children: tilesList,
                            );
                          }
                          return const Text('Ainda nao existem reservas');
                        }
                    ),
                  ),

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
              child: const Icon(Icons.shopping_cart, color: Colors.white,),
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
