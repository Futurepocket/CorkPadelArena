import 'package:cork_padel_arena/view/users.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/view/admin_reservations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cork_padel_arena/models/menuItem.dart';
import 'package:cork_padel_arena/models/page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/userr.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../apis/webservice.dart';
import 'admin_payments.dart';

class AdminDash extends StatefulWidget {

  @override
  _AdminDashState createState() => _AdminDashState();

}

class _AdminDashState extends State<AdminDash> {
  DatabaseReference database = FirebaseDatabase.instance.ref();
  checkoutValue _check = checkoutValue();
  var myName;

  getUser() async{
    await currentUser().then((value) {
      setState(() {
        myName = Userr().name;
      });
    });
  }
  settingState(){
    setState(() {

    });
  }
  @override
  void initState() {

    super.initState();
  }

  var client = http.Client();

  @override
  Widget build(BuildContext context) {
    Color _menuColor = Colors.grey.shade800;
    var menus = [
      Pages(
        Icon(Icons.supervised_user_circle_outlined, size: 120, color: _menuColor,),
        AppLocalizations.of(context)!.users,
        Theme.of(context).primaryColor,
            (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return Users();
          }));
        },
      ),
      Pages(
        Icon(Icons.list_alt_rounded, size: 120, color: _menuColor,),
        AppLocalizations.of(context)!.reservations,
        Theme.of(context).primaryColor,
            (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return AdminReservations();
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
        Icon(Icons.sensor_door_outlined, size: 120, color: _menuColor),
        '${AppLocalizations.of(context)!.openDoor}',
        Theme.of(context).primaryColor,
        (BuildContext ctx) {
         showWebView(context);
        }
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Align(
            alignment: Alignment.centerLeft,
            child: Text("Cork Padel Arena")),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body:
      SafeArea(
        child: SingleChildScrollView(

          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.symmetric(vertical:15, horizontal: 10),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.85,
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
                            children: menus
                                .map((menus) => MenuItem(
                                menus.ikon, menus.title, menus.color, menus.fun))
                                .toList(),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 350,
                              childAspectRatio: 0.5,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 0,
                              mainAxisExtent: 180,
                            ),
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
      floatingActionButton: Stack(
          children: [
            FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                showShoppingCart(context).then((value) {
                  settingState();
                });
              },
              child: Icon(Icons.shopping_cart, color: Colors.white,),
            ),

            _check.reservations == 0?
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
                child: Text(_check.reservations.toString(),
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
