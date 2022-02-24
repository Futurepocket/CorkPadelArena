// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAdDraOjTN66x9bmHSL5f8qdLutXzqYExo',
    appId: '1:951659670595:web:ef234d81c9cb0826adb8f6',
    messagingSenderId: '951659670595',
    projectId: 'corkpadel-arena-eb47b',
    authDomain: 'corkpadel-arena-eb47b.firebaseapp.com',
    databaseURL: 'https://corkpadel-arena-eb47b-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'corkpadel-arena-eb47b.appspot.com',
    measurementId: 'G-HXZVNJJSTY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBxl9RU-wcEOC6FOtYo2BqlYekWfUUPTw',
    appId: '1:951659670595:android:fdeb6403d63b0755adb8f6',
    messagingSenderId: '951659670595',
    projectId: 'corkpadel-arena-eb47b',
    databaseURL: 'https://corkpadel-arena-eb47b-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'corkpadel-arena-eb47b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArjGNKY3fpcURjRyaaUnMOr1DzaMHRtaY',
    appId: '1:951659670595:ios:399badff5f923752adb8f6',
    messagingSenderId: '951659670595',
    projectId: 'corkpadel-arena-eb47b',
    databaseURL: 'https://corkpadel-arena-eb47b-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'corkpadel-arena-eb47b.appspot.com',
    androidClientId: '951659670595-60otkfb0jb04mapr04eu4nvq0l1dsao2.apps.googleusercontent.com',
    iosClientId: '951659670595-qfo6kdk4q2kd0bjrf5odbth9ahamea4p.apps.googleusercontent.com',
    iosBundleId: 'com.corkpadel.arena',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyArjGNKY3fpcURjRyaaUnMOr1DzaMHRtaY',
    appId: '1:951659670595:ios:399badff5f923752adb8f6',
    messagingSenderId: '951659670595',
    projectId: 'corkpadel-arena-eb47b',
    databaseURL: 'https://corkpadel-arena-eb47b-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'corkpadel-arena-eb47b.appspot.com',
    androidClientId: '951659670595-60otkfb0jb04mapr04eu4nvq0l1dsao2.apps.googleusercontent.com',
    iosClientId: '951659670595-qfo6kdk4q2kd0bjrf5odbth9ahamea4p.apps.googleusercontent.com',
    iosBundleId: 'com.corkpadel.arena',
  );
}
