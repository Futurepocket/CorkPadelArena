import 'dart:convert';
import 'package:http_auth/http_auth.dart';
import 'package:cork_padel_arena/view/dash.dart';
import 'package:cork_padel_arena/view/users.dart';
import 'package:flutter/foundation.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cork_padel_arena/models/menuItem.dart';
import 'package:cork_padel_arena/models/page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../models/userr.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'admin_payments.dart';
import 'new_admin_reservations.dart';
import 'permanent_reservation.dart';

class AdminDash extends StatefulWidget {
  @override
  _AdminDashState createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  DatabaseReference database = FirebaseDatabase.instance.ref();
  checkoutValue _check = checkoutValue();
  var myName;

  getUser() async {
    await currentUser().then((value) {
      setState(() {
        myName = Userr().name;
      });
    });
  }

  settingState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Color _menuColor = Colors.grey.shade800;
    List<Pages> menus = [
      Pages(
        Icon(
          Icons.supervised_user_circle_outlined,
          size: 120,
          color: _menuColor,
        ),
        AppLocalizations.of(context)!.users,
        Theme.of(context).primaryColor,
        (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return const Users();
          }));
        },
      ),
      Pages(
        Icon(
          Icons.calendar_month_outlined,
          size: 120,
          color: _menuColor,
        ),
        AppLocalizations.of(context)!.reservations,
        Theme.of(context).primaryColor,
        (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return NewAdminReservations();
          }));
        },
      ),
      Pages(
        Icon(Icons.payments_outlined, size: 120, color: _menuColor),
        AppLocalizations.of(context)!.payments,
        Theme.of(context).primaryColor,
        (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return AdminPayments();
          }));
        },
      ),
      Pages(
        Icon(Icons.block, size: 120, color: _menuColor),
        AppLocalizations.of(context)!.adminReservation,
        Theme.of(context).primaryColor,
            (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return PermanentReservation();
          }));
        },
      ),
      Pages(
          Icon(Icons.sensor_door_outlined, size: 120, color: _menuColor),
          AppLocalizations.of(context)!.openDoor,
          Theme.of(context).primaryColor, (BuildContext ctx) async {
        if (kIsWeb) {
          launchUrlString(openDoorFullUrl);
        } else {
          var client = DigestAuthClient("admin", "cork2021");
          await client.get(Uri.parse(openDoorUrl)).then((response) {
            if(response.statusCode == 200){
              showWebView(context);
            }
          });
        }
      }),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Align(
            alignment: Alignment.centerLeft, child: Text("Cork Padel Arena")),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '${AppLocalizations.of(context)!.admin}',
                          style: TextStyle(
                            fontSize: 26,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          child: GridView(
                            padding: const EdgeInsets.all(5),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 350,
                              childAspectRatio: 0.5,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 0,
                              mainAxisExtent: 180,
                            ),
                            children: menus
                                .map((menus) => Menu_Item(menus.ikon,
                                    menus.title, menus.color, menus.fun))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(children: [
        FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            showShoppingCart(context).then((value) {
              settingState();
            });
          },
          child: Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
        ),
        _check.reservations == 0
            ? Positioned(top: 1.0, left: 1.0, child: Container())
            : Positioned(
                top: 1.0,
                left: 1.0,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    _check.reservations.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
      ]),
    );
  }
}
