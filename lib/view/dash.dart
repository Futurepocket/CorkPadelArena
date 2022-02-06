import 'dart:async';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/src/widgets.dart';
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
import 'admindash.dart';
import 'contacts.dart';
import 'myReservations.dart';

List<Reservation> reservationList = [];
List<Reservation> reservationsToCheckOut = [];
class Dash extends StatefulWidget {

  @override
  _DashState createState() => _DashState();

}

class _DashState extends State<Dash> {
  late bool isToday;
  late bool isIn10Mins;
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
    timer.cancel();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      deleteOldReservations();
      _removeFromDB();
    });
    setState(() {
      _check.reservations = reservationsToCheckOut.length;
    });
  }

  List<String> keys = [];
  void deleteOldReservations() {
    final DateTime today = DateTime.now();
    print(today);
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    database.child('reservations').onValue.listen((event) {
      if(event.snapshot.value != null){
        //reservationsToCheckOut.clear();
        _check.price = 0;
        Map<String, dynamic>.from(event.snapshot.value as dynamic)
            .forEach((key, value){
          final String whenMade = value['dateMade'] + ' ' + value['timeMade'];
          final String whenStarts = value['day'] + ' ' + value['hour'];
          final String whenEnds = value['day'] + ' ' + value['duration'];
          final DateTime made = formatter.parse(whenMade);
          final starts = formatter.parse(whenStarts);
          final ends = formatter.parse(whenEnds);

          if (today.isAfter(made.add(const Duration(minutes: 30))) &&
              value['state'] == 'por completar') {
            keys.add(key);
            if(value['client_email'] == Userr().email){
              reservationsToCheckOut.removeWhere((element) => element.id == key);
              setState(() {
                _check.reservations = reservationsToCheckOut.length;
                _check.price -= int.parse(value["price"]);
              });
            }
          }
          else if(today.isAfter(made.add(const Duration(hours: 24))) &&
              value['state'] == 'a aguardar pagamento'){
            keys.add(key);
          }
          else if((today.isAfter(starts.subtract(const Duration(hours: 12)))
              && today.isBefore(ends.add(const Duration(minutes: 10)))) &&
              value['state'] == 'pago' && value['client_email'] == Userr().email
              && reservedToday == null){

              setState(() {
                isToday = true;
                if(today.isAfter(starts.subtract(const Duration(minutes: 10)))
                    && today.isBefore(ends.add(const Duration(minutes: 10)))){
                  isIn10Mins = true;
                }else{
                  isIn10Mins = false;
                }
                reservedToday =
                    Reservation.fromRTDB(Map<String, dynamic>.from(value));
              });
          }
          else if((today.isAfter(starts.subtract(const Duration(hours: 12)))
              && today.isBefore(ends.add(const Duration(minutes: 10)))) &&
              value['state'] == 'pago' && value['client_email'] == Userr().email
              && reservedToday != null){
            final String whenMade = reservedToday!.day + ' ' +
                reservedToday!.hour;
            final DateTime theOneToday = formatter.parse(whenMade);
            if (starts.isBefore(theOneToday)){
              setState(() {
                isToday = true;
                if(today.isAfter(starts.subtract(const Duration(minutes: 10)))
                    && today.isBefore(ends.add(const Duration(minutes: 10)))){
                  isIn10Mins = true;
                }else{
                  isIn10Mins = false;
                }
                reservedToday =
                    Reservation.fromRTDB(Map<String, dynamic>.from(value));
              });
            }
          }else if(reservedToday != null){
            final String whenMade = reservedToday!.day + ' ' +
                reservedToday!.duration;
            final DateTime theOneTodayFinishes = formatter.parse(whenMade);
            if(today.isAfter(theOneTodayFinishes.add(const Duration(minutes:  10)))){
              setState(() {
                isIn10Mins = false;
                isToday = false;
                reservedToday = null;
              });
            }else if(today.isAfter(formatter.parse(reservedToday!.day + ' ' + reservedToday!.hour))
                && today.isBefore(formatter.parse(reservedToday!.day + ' ' + reservedToday!.duration))){
              setState(() {
                isIn10Mins = true;
                isToday = true;
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
  Reservation? reservedToday;
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
    isToday = false;
    isIn10Mins = false;
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
          })).then((value) => settingState());
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
          })).then((value) => settingState());
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
          })).then((value) => settingState());
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
        })).then((value) => settingState());
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
      }),
//TODO REMOVE COMMENTS HERE
      //if(Userr().role == "administrador")
        Pages(
            Icon(
              Icons.admin_panel_settings_outlined,
              color: _menuColor,
              size: 120,
            ),
            AppLocalizations.of(context)!.admin,
            Theme.of(context).primaryColor,
                (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (ctx) {
            return AdminDash();
          }));
        }
        ),
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
            isToday?
            Container(
              width:MediaQuery.of(context).size.width,
              height: 50,
              decoration: BoxDecoration(color: Colors.yellow.shade200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:8.0),
                    child: Text(
                      '${AppLocalizations.of(context)!.resToday} ${reservedToday!.hour}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:10.0),
                    child: StyledButton(
                        child: Text('${AppLocalizations.of(context)!.openDoor}',
                        style: TextStyle(color: isIn10Mins? Colors.white
                        : Colors.red
                        ),),
                        onPressed: isIn10Mins?
                            (){
                              launch('http://admin:cork2021@161.230.247.85:3333/cgi-bin/accessControl.cgi?action=openDoor&channel=1&UserID=101&Type=Remote');
                            }
                        :(){},
                        background: isIn10Mins ? Theme.of(context).primaryColor
                        : Colors.grey,
                        border: isIn10Mins ? Theme.of(context).primaryColor
                            : Colors.grey),
                  )
                ],
              ),
            ): Container(),
            Container(
                margin: EdgeInsets.symmetric(vertical:15, horizontal: 10),
                width: double.infinity,
                height: MediaQuery.of(context).size.height*0.85,
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
                    Userr().role == "administrador"?
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '${AppLocalizations.of(context)!.adminAccount}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                    )
                    : Container(),
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
                    FutureBuilder<void>(future: _launched, builder: _launchStatus)
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
