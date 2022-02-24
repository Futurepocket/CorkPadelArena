import 'package:url_launcher/url_launcher.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/view/admin_reservations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cork_padel_arena/models/menuItem.dart';
import 'package:cork_padel_arena/models/page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  //http://admin:cork2021@161.230.247.85:3333/cgi-bin/accessControl.cgi?action=openDoor&channel=1&UserID=101&Type=Remote
  Future _openDoor() async{
    launch('http://admin:cork2021@161.230.247.85:3333/cgi-bin/accessControl.cgi?action=openDoor&channel=1&UserID=101&Type=Remote');
    // var uri = Uri.http('161.230.247.85:3333','/cgi-bin/accessControl.cgi',
    //     {
    //       'action':'openDoor',
    //       'channel':'1',
    //       'UserID':'101',
    //     'Type':'Remote',
    //     });
    // print(uri);
    //   var response = await client.get(
    //       uri, headers: {
    //     HttpHeaders.authorizationHeader: 'Digest 59182b218225aa9df8aceafbd844b449, password="cork2021", realm="Login to 75fb9cb5fa02c1363cb51defd537db68", nonce="185879478", uri="/cgi-bin/accessControl.cgi?action=openDoor&channel=1&UserID=101&Type=Remote", response="e58778dcddb7bca9059a932b58d61a90", opaque="4f135eda3ef76399c88388e7eafbaa479985a12a", cnonce="f291c102cf6326cc87a8e2e7f130eee7", nc=00000001, qop="auth"',
    //     'Accept-Language': 'en-GB,en;q=0.9',
    //   'Accept-Encoding': 'gzip, deflate',
    //     'Connection':'keep-alive',
    //     'Upgrade-Insecure-Requests': '1',
    //   }).timeout(const Duration(seconds: 20));
    //   print(response.reasonPhrase);
    //   print(response.statusCode);
    // if (response.statusCode == 200) {
    //    print('Success');
    // } else {
    //   Map<String, dynamic> error = jsonDecode(response.body);
    //   throw Exception(error["message"]);
    // }

  }

  @override
  Widget build(BuildContext context) {
    Color _menuColor = Colors.grey.shade800;
    var menus = [
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
         _openDoor();
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
