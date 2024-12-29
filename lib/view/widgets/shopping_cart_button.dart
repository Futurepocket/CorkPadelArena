import 'package:cork_padel_arena/main.dart';
import 'package:cork_padel_arena/models/ReservationStreamPublisher.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/view/dash.dart';
import 'package:cork_padel_arena/view/login/login.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ShoppingCartButton extends StatelessWidget {
  const ShoppingCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        key: UniqueKey(),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton.extended(
            key: UniqueKey(),
            onPressed: () async => await launchUrlString('tel://912482338', mode: LaunchMode.externalApplication),
            label: Text("Assistência", style: TextStyle(color: Colors.black),),
            icon: Icon(Icons.phone,color: Theme.of(context).colorScheme.onSecondary),
            backgroundColor: Theme.of(context).colorScheme.secondary,),
          Text("Versão ${packageInfo.version}"),
          StreamBuilder<List<Reservation>>(
              key: UniqueKey(),
              stream: ReservationStreamPublisher().getReservationStream(),
              builder: (context, snapshot) {
                late Widget button;

                if (snapshot.hasData) {
                  List reservations = snapshot.data as List<Reservation>;
                  int i = 0;
                  do {
                    if (reservations.isNotEmpty) {
                      if (reservations[i].userEmail != Userr().email) {
                        reservations.removeAt(i);
                        i = i;
                      } else if (reservations[i].userEmail == Userr().email &&
                          reservations[i].state != 'por completar') {
                        reservations.removeAt(i);
                        i = i;
                      } else
                        i++;
                    }
                  } while (i < reservations.length);

                  button = Badge(
                    label: Text(reservations.length.toString()),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    isLabelVisible: reservations.isEmpty ? false : true,
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        showShoppingCart(context);
                      },
                      child: Icon(Icons.shopping_cart,
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                  );
                }else{
                  button = FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      showShoppingCart(context);
                    },
                    child: Icon(Icons.shopping_cart,
                        color: Theme.of(context).colorScheme.onSecondary),
                  );
                }

                // }

                return button;

              })
        ],
      ),
    );
  }
}
