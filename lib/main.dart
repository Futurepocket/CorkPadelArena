import 'package:cork_padel_arena/register/register.dart';
import 'package:cork_padel_arena/register/user_details.dart';
import 'package:cork_padel_arena/src/registerSplash.dart';
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
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'view/login/login.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  ).whenComplete(() => print("Firebase started"));
  init();
  // Get any initial links
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  runApp(
    kIsWeb? Center(
      child: SizedBox(
      width: 400,
        child: new MyApp(initialLink),
    ),)
      : new MyApp(initialLink));
}

class MyApp extends StatefulWidget {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  final initialLink;
  MyApp(this.initialLink);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    if (widget.initialLink != null) {
      final Uri deepLink = widget.initialLink.link;
      // Example of using the dynamic link to push the user to a different screen
      Navigator.pushNamed(context, deepLink.path);
    }
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {
      // Handle errors
    });
    super.initState();
  }
  final Map<int, Color> _colorMap = {
    50: Color.fromRGBO(190, 255, 249, 1),
    100: Color.fromRGBO(190, 255, 229, 1),
    200: Color.fromRGBO(190, 255, 209, 1),
    300: Color.fromRGBO(190, 255, 189, 1),
    400: Color.fromRGBO(190, 255, 169, 1),
    500: Color.fromRGBO(190, 255, 149, 1),
    600: Color.fromRGBO(190, 255, 129, 1),
    700: Color.fromRGBO(190, 255, 109, 1),
    800: Color.fromRGBO(190, 247, 89, 1),
    900: Color.fromRGBO(190, 227, 69, 1),
    1000: Color.fromRGBO(190, 207, 49, 1)
  };

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

