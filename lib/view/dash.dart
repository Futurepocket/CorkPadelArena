import 'dart:async';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:cork_padel_arena/main.dart';
import 'package:cork_padel_arena/models/menuItem.dart';
import 'package:cork_padel_arena/models/page.dart';
import 'package:cork_padel_arena/view/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/userr.dart';
import './reserve.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'contacts.dart';
import 'myReservations.dart';

enum UserDetailState {
  noDetails,
  notVerified,
  verified,
}

class Dash extends StatefulWidget {

  @override
  _DashState createState() => _DashState();

}

class _DashState extends State<Dash> {
  UserDetailState _userState = UserDetailState.verified;
  UserDetailState get loginState => _userState;
  DatabaseReference database = FirebaseDatabase.instance.ref();
  checkoutValue _check = checkoutValue();
  var myName;
  Future<void>? _launched;

  final _url = 'https://www.corkpadel.pt/en/store';

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  didChangeDependencies(){
    setState(() {
      _check.reservations = reservationsToCheckOut.length;
      _check.price = _check.reservations * 10;
    });
  }

  List<String> keys = [];
  void deleteOldReservations() {
    final DateTime today = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    database.child('reservations').onValue.listen((event) {
      if(event.snapshot.value != null){
        Map<String, dynamic>.from(event.snapshot.value as dynamic)
            .forEach((key, value){
          final String whenMade = value['dateMade'] + ' ' + value['timeMade'];
          final DateTime dbDay = formatter.parse(whenMade);

          if (today.isAfter(dbDay.add(const Duration(minutes: 30))) &&
              value['state'] == 'por completar') {
            keys.add(key);
            if(value['client_email'] == Userr().email){
              reservationsToCheckOut.removeWhere((element) => element.id == key);
              setState(() {
                _check.reservations = reservationsToCheckOut.length;
                _check.price = _check.reservations * 10;
              });
            }
          }
        });
      }
    });
  }
  _removeFromDB(){
    for(String key in keys){
      print(key);
      database.child('reservations').child(key).remove();
    }
    keys.clear();
  }

  settingState(){
    setState(() {

    });
  }

  late Timer timer;

  getUser() async{
    await currentUser().then((value) {
      setState(() {
        myName = Userr().name;
      });
  });
        }
  @override
  void initState() {
    getUser();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      deleteOldReservations();
      _removeFromDB();
    });
    super.initState();
  }

  void setIt() {
    setState(() {
      _launched = _launchInBrowser(_url);
    });
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color _menuColor = Colors.grey.shade800;
    var menus = [
      Pages(
        Icon(Icons.person, size: 120, color: _menuColor,),
        AppLocalizations.of(context)!.profile,
        Theme.of(context).primaryColor,
            (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return Profile();
          }));
        },
      ),
      Pages(
        Icon(Icons.calendar_today_outlined, size: 120, color: _menuColor),
        AppLocalizations.of(context)!.makeReservation,
        Theme.of(context).primaryColor,
            (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return Reserve();
          }));
        },
      ),
      Pages(
        Icon(Icons.list_alt_rounded, size: 120, color: _menuColor),
        AppLocalizations.of(context)!.myReservations,
        Theme.of(context).primaryColor,
            (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return MyReservations();
          }));
        },
      ),
      Pages(
          Icon(
            Icons.contact_phone,
            color: _menuColor,
            size: 120,
          ),
          AppLocalizations.of(context)!.contacts,
          Theme.of(context).primaryColor, (BuildContext ctx) {
        Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) {
          return Contacts();
        }));
      }),
      Pages(
        Icon(
          Icons.shopping_bag_rounded,
          color: _menuColor,
          size: 120,
        ),
        AppLocalizations.of(context)!.onlineShop,
        Theme.of(context).primaryColor,
            (BuildContext ctx) async {
          if (await canLaunch('https://www.corkpadel.pt/en/store')) {
            await launch(
              'https://www.corkpadel.pt/en/store',
              forceWebView: false,
              //headers: <String, String>{'my_header_key': 'my_header_value'},
            );
          } else {
            throw 'Could not launch the store';
          }
        },
      ),
      Pages(
          Icon(
            Icons.exit_to_app_rounded,
            color: _menuColor,
            size: 120,
          ),
          AppLocalizations.of(context)!.logout,
          Theme.of(context).primaryColor, (BuildContext ctx) {
        FirebaseAuth.instance.signOut();
        Navigator.of(
          ctx,
        ).pushReplacement(MaterialPageRoute(builder: (ctx) {
          return MyApp();
        }));
      })
    ];

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
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
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '${AppLocalizations.of(context)!.welcome} ${myName}',
                        style: TextStyle(
                          fontSize: 26,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView(
                        padding: const EdgeInsets.all(5),
                        children: menus
                            .map((menus) => MenuItem(
                            menus.ikon, menus.title, menus.color, menus.fun))
                            .toList(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 350,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                         mainAxisExtent: 190,
                        ),
                      ),
                    ),
                    FutureBuilder<void>(future: _launched, builder: _launchStatus)
                  ],
                )),
          ],
    ),
       ),
     ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: shopCart(context, settingState),
    );
  }

}
