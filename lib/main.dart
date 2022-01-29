import 'package:cork_padel_arena/register/register.dart';
import 'package:cork_padel_arena/register/user_details.dart';
import 'package:cork_padel_arena/src/registerSplash.dart';
import 'package:cork_padel_arena/view/dash.dart';
import 'package:cork_padel_arena/view/email_verify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'view/login/login.dart';

// import 'package:square_in_app_payments/models.dart';
// import 'package:square_in_app_payments/in_app_payments.dart';
//import 'package:square_in_app_payments/google_pay_constants.dart' as google_pay_constants;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDBxl9RU-wcEOC6FOtYo2BqlYekWfUUPTw",
        authDomain: "corkpadel-arena-eb47b.web.app.firebaseapp.com",
        databaseURL: "https://corkpadel-arena-eb47b-default-rtdb.europe-west1.firebasedatabase.app/",
        storageBucket: "gs://corkpadel-arena-eb47b.appspot.com",
        appId: "1:951659670595:android:55a5fe8c00e40080adb8f6",
        messagingSenderId: '951659670595',
        projectId: "corkpadel-arena-eb47b")
  ).whenComplete(() => print("Firebase started"));
  runApp(
    kIsWeb? Center(
      child: SizedBox(
      width: 400,
        child: new MyApp(),
    ),)
      : new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Future<void> _initSquarePayment() async {
  //   await InAppPayments.setSquareApplicationId('APPLICATION_ID');
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('pt', ''), // Portuguese, no country code
      ],
      title: 'Cork Padel',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 24, fontFamily: GoogleFonts.robotoCondensed().fontFamily),
            iconTheme: IconThemeData(color: Colors.white)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: Colors.lime,
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      initialRoute: '/login',
      routes: {
//        '/': (context) => HomePage(),
        '/login': (context) => Login(),
        '/dash': (context) => Dash(),
        '/register': (context) => Register(),
        '/splash':(context) => RegisterSplash(),
        '/emailVerify': (context) => EmailVerify(),
        '/userDetails': (context) => UserDetails()
      }
    );
  }
}

