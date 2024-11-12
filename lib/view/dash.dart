import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/constants/constants.dart';
import 'package:cork_padel_arena/main.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/src/constants.dart';
import 'package:cork_padel_arena/src/widgets.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/view/login/login.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:http_auth/http_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cork_padel_arena/models/menuItem.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/userr.dart';

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
  late bool canOpen;
  int earlyOpenDuration = 15;
  DatabaseReference database = FirebaseDatabase.instance.ref();
  var myName;
  Future<void>? _launched;
  final _url = 'https://www.corkpadel.pt/en/store';

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    timer.cancel();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
    database.child(reservationDatabase).onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic>.from(event.snapshot.value as dynamic)
            .forEach((key, value) {
          if (value['dateMade'] != null) {
            final String whenMade = value['dateMade'] + ' ' + value['timeMade'];
            String whenStarts = value['day'] + ' ' + value['hour'];
            String whenEnds = value['day'] + ' ' + value['duration'];
            if (whenEnds == '00:00') {
              whenEnds = '24:00';
            }
            if (whenEnds == '00:30') {
              whenEnds = '24:30';
            }
            final DateTime made = formatter.parse(whenMade);
            final starts = formatter.parse(whenStarts);
            final ends = formatter.parse(whenEnds);

            if ((today.isAfter(made.add(const Duration(minutes: 30))) &&
                    value['state'] == 'por completar') ||
                today.isAfter(made.add(const Duration(days: 90)))) {
              keys.add(key);
              if (value['client_email'] == Userr().email &&
                  reservationsToCheckOut.any((element) => element.id == key)) {
                reservationsToCheckOut
                    .removeWhere((element) => element.id == key);
                setState(() {
                  checkoutValue().reservations = reservationsToCheckOut.length;
                  checkoutValue().price -= int.parse(value["price"]);
                });
              }
            } else if (today.isAfter(made.add(const Duration(hours: 24))) &&
                value['state'] == 'a aguardar pagamento') {
              keys.add(key);
            } else if ((today
                        .isAfter(starts.subtract(const Duration(hours: 12))) &&
                    today.isBefore(ends.add(const Duration(minutes: 10)))) &&
                value['state'] == 'pago' &&
                value['client_email'] == Userr().email &&
                reservedToday == null) {
              setState(() {
                isToday = true;
                if (today.isAfter(starts
                        .subtract(Duration(minutes: earlyOpenDuration))) &&
                    today.isBefore(
                        ends.add(Duration(minutes: earlyOpenDuration)))) {
                  canOpen = true;
                } else {
                  canOpen = false;
                }
                reservedToday =
                    Reservation.fromRTDB(Map<String, dynamic>.from(value));
              });
            } else if ((today
                        .isAfter(starts.subtract(const Duration(hours: 12))) &&
                    today.isBefore(
                        ends.add(Duration(minutes: earlyOpenDuration)))) &&
                value['state'] == 'pago' &&
                value['client_email'] == Userr().email &&
                reservedToday != null) {
              final String whenMade =
                  '${reservedToday!.day} ${reservedToday!.hour}';
              final DateTime theOneToday = formatter.parse(whenMade);
              if (starts.isBefore(theOneToday)) {
                setState(() {
                  isToday = true;
                  if (today.isAfter(starts
                          .subtract(Duration(minutes: earlyOpenDuration))) &&
                      today.isBefore(
                          ends.add(Duration(minutes: earlyOpenDuration)))) {
                    canOpen = true;
                  } else {
                    canOpen = false;
                  }
                  reservedToday =
                      Reservation.fromRTDB(Map<String, dynamic>.from(value));
                });
              }
            } else if (reservedToday != null) {
              final String whenMade =
                  reservedToday!.day + ' ' + reservedToday!.duration;
              final DateTime theOneTodayFinishes = formatter.parse(whenMade);
              if (today.isAfter(theOneTodayFinishes
                  .add(Duration(minutes: earlyOpenDuration)))) {
                setState(() {
                  canOpen = false;
                  isToday = false;
                  reservedToday = null;
                });
              } else if (today.isAfter(formatter
                      .parse('${reservedToday!.day} ${reservedToday!.hour}')) &&
                  today.isBefore(formatter.parse(
                      '${reservedToday!.day} ${reservedToday!.duration}'))) {
                setState(() {
                  canOpen = true;
                  isToday = true;
                });
              }
            }
          }
        });
      }
    });
  }

  _removeFromDB() {
    for (String key in keys) {
      database.child(reservationDatabase).child(key).remove();
    }
    keys.clear();
  }

  Reservation? reservedToday;

  settingState() {
    setState(() {});
  }

  late Timer timer;

  getUser() async {
    await currentUser().then((value) {
      setState(() {
        myName = Userr().name;
      });
    });
  }

  @override
  void initState() {
    isToday = false;
    canOpen = false;
    final instance = FirebaseFirestore.instance.collection('constants');

    instance.doc("appVersion").get().then((value) {
      setState(() {
        appVersion = value.data()!["version"];
      });
    });
    instance.doc("userOpenBefore").get().then((value) {
      setState(() {
        earlyOpenDuration = value.data()!["duration"];
      });
    });

    instance.doc('openDoorUrlID').get().then((value) {
      openDoorUrl = value.data()!['url'];
    });
    instance
        .doc("openDoorFullUrl")
        .get()
        .then((value) => openDoorFullUrl = value.data()!["url"]);
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
    localizations = AppLocalizations.of(context)!;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Align(
            alignment: Alignment.center, child: Text("Cork Padel Arena")),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: !kIsWeb && appVersion != packageInfo.version
              ? Container(
                  height: MediaQuery.of(context).size.height - 200,
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(localizations.differentAppVersion, textAlign: TextAlign.center,),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: ElevatedButton(
                            onPressed: () {
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
                            },
                            child: Text(localizations.updateApp)),
                      )
                    ],
                  ),
                )
              : Column(
                  children: [
                    isToday
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration:
                                BoxDecoration(color: Colors.yellow.shade200),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '${localizations.resToday} ${reservedToday!.hour}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: StyledButton(
                                      onPressed: canOpen
                                          ? () {
                                              launchUrl(
                                                  Uri.parse(openDoorFullUrl));
                                            }
                                          : null,
                                      child: Text(
                                        localizations.openDoor,
                                      )),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                '${localizations.welcome} $myName',
                                style: const TextStyle(
                                  fontSize: 26,
                                ),
                              ),
                            ),
                            Userr().role == "administrador"
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      localizations.adminAccount,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  )
                                : Container(),
                            Expanded(
                              child: Scrollbar(
                                child: GridView(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 150,
                                    childAspectRatio: 0.5,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                    mainAxisExtent: 150,
                                  ),
                                  children:
                                      getDashButtons(context, settingState)
                                          .map((menus) => Menu_Item(
                                                ikon: menus.ikon,
                                                title: menus.title,
                                                fun: menus.fun,
                                              ))
                                          .toList(),
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
      floatingActionButton: !kIsWeb && appVersion != packageInfo.version? null : Badge(
        label: Text(reservationsToCheckOut.length.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
        isLabelVisible: reservationsToCheckOut.isEmpty ? false : true,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            showShoppingCart(context).then((value) {
              settingState();
            });
          },
          child: Icon(Icons.shopping_cart,
              color: Theme.of(context).colorScheme.onSecondary),
        ),
      ),
    );
  }
}
