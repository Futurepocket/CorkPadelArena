import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/register/register.dart';
import 'package:cork_padel_arena/register/user_details.dart';
import 'package:cork_padel_arena/src/registerSplash.dart';
import 'package:cork_padel_arena/utils/custom_proxy.dart';

import 'package:cork_padel_arena/utils/firebase_utils.dart';
import 'package:cork_padel_arena/view/dash.dart';
import 'package:cork_padel_arena/view/email_verify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'view/login/login.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  if (false) {
    //const charlesIp = String.fromEnvironment('CHARLES_PROXY_IP');

    // For Android devices you can also allowBadCertificates: true below, but you should ONLY do this when !kReleaseMode
    final proxy = CustomProxy(ipAddress: 'localhost', port: 8888, allowBadCertificates: true);
    proxy.enable();
  }
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  ).whenComplete(() async{
    //initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  });
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await init();

  runApp(
    kIsWeb? const Center(
      child: SizedBox(
      width: 400,
        child:  MyApp(),
    ),)
      :  const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<int, Color> _colorMap = {
    50: const Color.fromRGBO(190, 255, 249, 1),
    100: const Color.fromRGBO(190, 255, 229, 1),
    200: const Color.fromRGBO(190, 255, 209, 1),
    300: const Color.fromRGBO(190, 255, 189, 1),
    400: const Color.fromRGBO(190, 255, 169, 1),
    500: const Color.fromRGBO(190, 255, 149, 1),
    600: const Color.fromRGBO(190, 255, 129, 1),
    700: const Color.fromRGBO(190, 255, 109, 1),
    800: const Color.fromRGBO(190, 247, 89, 1),
    900: const Color.fromRGBO(190, 227, 69, 1),
    1000: const Color.fromRGBO(190, 207, 49, 1)
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,

      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('pt', ''), // Portuguese, no country code
      ],
      title: 'Cork Padel',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 24, fontFamily: GoogleFonts.robotoCondensed().fontFamily),
            iconTheme: const IconThemeData(color: Colors.white)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: MaterialColor(_colorMap[1000]!.value, _colorMap),
        fontFamily: 'ApexSans',
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

