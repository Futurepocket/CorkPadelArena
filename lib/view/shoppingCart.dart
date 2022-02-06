import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cork_padel_arena/models/ReservationStreamPublisher.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/src/widgets.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:flutter/material.dart';
import 'checkout.dart';

class ShoppingCart extends StatefulWidget {

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  Userr _user = Userr();
  checkoutValue _check = checkoutValue();
  var number;
  List listForLength = <Card>[];
  DatabaseReference database = FirebaseDatabase.instance.ref();

  @override
  void didChangeDependencies() {
setState(() {

});
  }
  @override
  Widget build(BuildContext context) {
    number = 0;
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey.shade100),
      child: Column(
        children: [
          Text(
            'Carrinho',
            style: TextStyle(
              fontFamily: 'Roboto Condensed',
              fontSize: 26,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: StreamBuilder(
                  stream: ReservationStreamPublisher().getReservationStream(),
                  builder: (context, snapshot) {
                    final tilesList = <Card>[];

                    if (snapshot.hasData) {
                      List reservations = snapshot.data as List<Reservation>;
                      int i = 0;
                      do {
                        if (reservations.isNotEmpty) {
                          if (reservations[i].userEmail != _user.email) {
                            reservations.removeAt(i);
                            i = i;
                          } else if (reservations[i].userEmail == _user.email &&
                              reservations[i].state != 'por completar') {
                            reservations.removeAt(i);
                            i = i;
                          } else
                            i++;
                        }
                      } while (i < reservations.length);
                        reservationsToCheckOut = reservations as List<Reservation>;
                      try {
                        tilesList.addAll(reservations.map((nextReservation) {

                          // if (_user.email == nextReservation.userEmail &&
                          //     nextReservation.state == 'por completar') {
                          return Card(
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(Icons.watch),
                              title: Text('Dia ' + nextReservation.day),
                              subtitle: Text('Das ' +
                                  nextReservation.hour +
                                  ' as ' +
                                  nextReservation.duration),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleting(context, nextReservation.id, nextReservation.price);
                                },
                              ),
                            ),
                          );
                          // } else {
                          //   throw Exception();
                          // }
                        }));
                      } catch (e) {
                        return Text('O carrinho esta vazio');
                      }
                    }else{
                      _check.reservations = 0;
                      reservationsToCheckOut.clear();
                    }
                    // }
                    if (tilesList.isNotEmpty) {
                      return Column(
                        children: [
                          Expanded(
                            //padding: EdgeInsets.all(0),
                            child: ListView(
                              children: tilesList,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Total:',
                                style: TextStyle(
                                  fontFamily: 'Roboto Condensed',
                                  fontSize: 26,
                                ),
                              ),
                              Text(
                                '€ ${_check.price.toString()}.00',
                                style: TextStyle(
                                  fontFamily: 'Roboto Condensed',
                                  fontSize: 26,
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.all(15),
                                  width: 150,
////////////////////// BUTTON TO RESERVE ////////////////////////////////////////////////
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Theme.of(context).primaryColor,
                                        onPrimary: Colors.white,
                                      ),
                                      child: Text(
                                        Userr().role == 'administrador'? "Finalizar"
                                        :"Pagamento",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      onPressed: () {
                                        if(Userr().role == 'administrador'){
                                          final reservations = database.child('reservations');
                                          reservationsToCheckOut.forEach((element) async{
                                            try {
                                              //await reservations.set(_reservation);
                                              await reservations.child(element.id).child("state").set('pago');
                                              await reservations.child(element.id).child("completed").set(true);
                                              Navigator.of(context).pop(true);
                                              reservationsToCheckOut.clear();
                                              _check.reservations = 0;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                  newSnackBar(context, Text('Reservas Efetuadas')));
                                            } catch (e) {
                                              print('There is an error!');
                                            }
                                          });
                                        }
                                        else
                                        Navigator.of(
                                          context,
                                        ).push(
                                          MaterialPageRoute(builder: (_) {
                                            return Checkout();
                                          }),
                                        );
                                      }))
                            ],
                          ),
                        ],
                      );
                    }
                    return Text(AppLocalizations.of(context)!.shoppingCartEmpty);
                  }),
            ),
          ),
        ],
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
                  _check.price -= int.parse(price);
                  _database.remove();
                  _check.reservations -= 1;

                  reservationsToCheckOut.removeWhere((element) => element.id == id);
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
