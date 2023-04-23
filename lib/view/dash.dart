import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/src/widgets.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/view/login/login.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:http_auth/http_auth.dart';
import 'package:intl/intl.dart';
import 'package:cork_padel_arena/main.dart';
import 'package:cork_padel_arena/models/menuItem.dart';
import 'package:cork_padel_arena/models/page.dart';
import 'package:cork_padel_arena/view/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/userr.dart';
import './reserve.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'admindash.dart';
import 'contacts.dart';
import 'new_my_reservations.dart';

List<Reservation> reservationList = [];
List<Reservation> reservationsToCheckOut = [];
String openDoorUrl = '';
String openDoorFullUrl = '';
class Dash extends StatefulWidget {
  const Dash({Key? key}) : super(key: key);


  @override
  _DashState createState() => _DashState();

}

class _DashState extends State<Dash> {
  late bool isToday;
  late bool isIn10Mins;
  DatabaseReference database = FirebaseDatabase.instance.ref();
  var myName;
  Future<void>? _launched;
  final _url = 'https://www.corkpadel.pt/en/store';

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  didChangeDependencies(){
    super.didChangeDependencies();
    timer.cancel();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      deleteOldReservations();
      _removeFromDB();
    });
    setState(() {
      checkoutValue().reservations = reservationsToCheckOut.length;
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
              if(value['dateMade'] != null){
                final String whenMade = value['dateMade'] + ' ' + value['timeMade'];
                String whenStarts = value['day'] + ' ' + value['hour'];
                String whenEnds = value['day'] + ' ' + value['duration'];
                if(whenEnds == '00:00'){
                  whenEnds = '24:00';
                }
                if(whenEnds == '00:30'){
                  whenEnds = '24:30';
                }
                final DateTime made = formatter.parse(whenMade);
                final starts = formatter.parse(whenStarts);
                final ends = formatter.parse(whenEnds);

                if ((today.isAfter(made.add(const Duration(minutes: 30))) &&
                    value['state'] == 'por completar') || today.isAfter(made.add(const Duration(days: 90)))) {
                  keys.add(key);
                  if(value['client_email'] == Userr().email && reservationsToCheckOut.any((element) => element.id == key)){
                    reservationsToCheckOut.removeWhere((element) => element.id == key);
                    setState(() {
                      checkoutValue().reservations = reservationsToCheckOut.length;
                      checkoutValue().price -= int.parse(value["price"]);
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
              }
        });
      }
    });
  }
  _removeFromDB(){
    for(String key in keys){
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
    final instance = FirebaseFirestore.instance
        .collection('constants');

    instance.doc("appVersion").get().then((value) {
      setState(() {
        appVersion = value.data()!["version"];
      });
    });
    instance.doc('openDoorUrlID').get().then((value) {
      openDoorUrl = value.data()!['url'];
    });
    instance.doc("openDoorFullUrl").get().then((value) => openDoorFullUrl = value.data()!["url"]);
    getUser();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
          ).pushNamed("/profile").then((value) => settingState());
        },
      ),
      Pages(
        Icon(Icons.edit_calendar_outlined, size: 120, color: _menuColor),
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
        Icon(Icons.calendar_month_outlined, size: 120, color: _menuColor),
        AppLocalizations.of(context)!.myReservations,
        Theme.of(context).primaryColor,
            (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return NewMyReservations();
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
          Theme.of(context).primaryColor,
              (BuildContext ctx) {
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
          if (await canLaunchUrl(Uri.parse('https://www.corkpadel.pt/en/store'))) {
            await launchUrl(
              Uri.parse('https://www.corkpadel.pt/en/store'),
              mode: LaunchMode.platformDefault,
              //headers: <String, String>{'my_header_key': 'my_header_value'},
            );
          } else {
            throw 'Could not launch the store';
          }
        },
      ),
      // Pages(
      //   Icon(
      //     Icons.device_unknown,
      //     color: _menuColor,
      //     size: 120,
      //   ),
      //   AppLocalizations.of(context)!.about,
      //   Theme.of(context).primaryColor,
      //         (BuildContext ctx) {
      //       Navigator.of(
      //         ctx,
      //       ).push(MaterialPageRoute(builder: (_) {
      //         return AboutUs();
      //       })).then((value) => settingState());
      //     }
      // ),
      if(Userr().role == "administrador")
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
    ];

    if(!kIsWeb) {
      return UpgradeAlert(
        upgrader: Upgrader(
            canDismissDialog: false,
            countryCode: "PT",
            languageCode: "PT",
            minAppVersion: appVersion,
            onIgnore: () {
              Navigator.of(context).pop();
              return false;
            },
            onLater: () {
              Navigator.of(context).pop();
              return false;
            },
            onUpdate: () {
              if (Platform.isIOS) {
                launchUrl(
                  Uri.parse(
                      'https://apps.apple.com/pt/app/cork-padel-arena/id1607689892'),
                  mode: LaunchMode.externalApplication,
                  //headers: <String, String>{'my_header_key': 'my_header_value'},
                );
              }
              if (Platform.isAndroid) {
                launchUrl(
                  Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.corkpadel.arena'),
                  mode: LaunchMode.externalApplication,
                  //headers: <String, String>{'my_header_key': 'my_header_value'},
                );
              }
              return false;
            }
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Align(
                alignment: Alignment.center,
                child: Text("Cork Padel Arena")),
            backgroundColor: Theme
                .of(context)
                .primaryColor,
          ),
          body:
          SafeArea(
            child: SingleChildScrollView(

              child: Column(
                children: [
                  isToday ?
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 50,
                    decoration: BoxDecoration(color: Colors.yellow.shade200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '${AppLocalizations.of(context)!
                                .resToday} ${reservedToday!.hour}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: StyledButton(
                              onPressed: isIn10Mins ?
                                  () async {
                                if (kIsWeb) {
                                  launchUrl(Uri.parse(openDoorFullUrl));
                                } else {
                                  var client = DigestAuthClient(
                                      "admin", "cork2021");
                                  await client.get(Uri.parse(openDoorUrl)).then((
                                      response) {
                                    if (response.statusCode == 200) {
                                      showWebView(context);
                                    }
                                  });
                                }
                              }
                                  : () {},
                              background: isIn10Mins ? Theme
                                  .of(context)
                                  .primaryColor
                                  : Colors.grey,
                              border: isIn10Mins ? Theme
                                  .of(context)
                                  .primaryColor
                                  : Colors.grey,
                              child: Text(AppLocalizations.of(context)!.openDoor,
                                style: TextStyle(color: isIn10Mins ? Colors.white
                                    : Colors.red
                                ),)),
                        )
                      ],
                    ),
                  ) : Container(),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      width: double.infinity,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.85,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '${AppLocalizations.of(context)!
                                  .welcome} ${myName}',
                              style: TextStyle(
                                fontSize: 26,
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                              ),
                            ),
                          ),
                          Userr().role == "administrador" ?
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
                                    .map((menus) =>
                                    Menu_Item(
                                        menus.ikon, menus.title, menus.color,
                                        menus.fun))
                                    .toList(),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 350,
                                  childAspectRatio: 0.5,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 0,
                                  mainAxisExtent: 180,
                                ),
                              ),
                            ),
                          ),
                          FutureBuilder<void>(
                              future: _launched, builder: _launchStatus)
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
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  onPressed: () {
                    showShoppingCart(context).then((value) {
                      settingState();
                    });
                  },
                  child: Icon(Icons.shopping_cart, color: Colors.white,),
                ),

                reservationsToCheckOut.isEmpty ?
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
        ),
      );
    }else {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Align(
              alignment: Alignment.center,
              child: Text("Cork Padel Arena")),
          backgroundColor: Theme
              .of(context)
              .primaryColor,
        ),
        body:
        SafeArea(
          child: SingleChildScrollView(

            child: Column(
              children: [
                isToday ?
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.yellow.shade200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${AppLocalizations.of(context)!
                              .resToday} ${reservedToday!.hour}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: StyledButton(
                            onPressed: isIn10Mins ?
                                () async {
                              if (kIsWeb) {
                                launchUrl(Uri.parse(openDoorFullUrl));
                              } else {
                                var client = DigestAuthClient(
                                    "admin", "cork2021");
                                await client.get(Uri.parse(openDoorUrl)).then((
                                    response) {
                                  if (response.statusCode == 200) {
                                    showWebView(context);
                                  }
                                });
                              }
                            }
                                : () {},
                            background: isIn10Mins ? Theme
                                .of(context)
                                .primaryColor
                                : Colors.grey,
                            border: isIn10Mins ? Theme
                                .of(context)
                                .primaryColor
                                : Colors.grey,
                            child: Text(AppLocalizations.of(context)!.openDoor,
                              style: TextStyle(color: isIn10Mins ? Colors.white
                                  : Colors.red
                              ),)),
                      )
                    ],
                  ),
                ) : Container(),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    width: double.infinity,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.85,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '${AppLocalizations.of(context)!
                                .welcome} ${myName}',
                            style: TextStyle(
                              fontSize: 26,
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                            ),
                          ),
                        ),
                        Userr().role == "administrador" ?
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
                                  .map((menus) =>
                                  Menu_Item(
                                      menus.ikon, menus.title, menus.color,
                                      menus.fun))
                                  .toList(),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 350,
                                childAspectRatio: 0.5,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                mainAxisExtent: 180,
                              ),
                            ),
                          ),
                        ),
                        FutureBuilder<void>(
                            future: _launched, builder: _launchStatus)
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
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                onPressed: () {
                  showShoppingCart(context).then((value) {
                    settingState();
                  });
                },
                child: Icon(Icons.shopping_cart, color: Colors.white,),
              ),

              reservationsToCheckOut.isEmpty ?
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

}
