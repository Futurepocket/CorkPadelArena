import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/view/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';

Future<void> init() async {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
  FirebaseAuth.instance.userChanges().listen((user) {
    if (user != null) {
      //_loginState = ApplicationLoginState.loggedIn;
    } else {
      //_loginState = ApplicationLoginState.loggedOut;
    }
  });
}

String? _email;

String? get email => _email;
User? fbUser;
bool? emailVerified;

void checkEmail(
  String email,
  void Function(FirebaseAuthException e) errorCallback,
) async {
  try {
    var methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (methods.contains('password')) {
      //TODO
    } else {
      //_loginState = ApplicationLoginState.register;
    }
    //_email = email;
  } on FirebaseAuthException catch (e) {
    errorCallback(e);
  }
}

Future<bool> checkEmailVerified(User user) async {
  if (user.emailVerified) {
    emailVerified = true;
    return true;
  } else {
    emailVerified = false;
    return false;
  }
}

Future<User?> signInWithEmailAndPassword(
  String email,
  String password,
  void Function(FirebaseAuthException e) errorCallback,
) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) async {

      String clientType = kIsWeb ? "WEB_APP" : "MOBILE_APP";

      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('setCustomClaim');

      await callable.call({
        'uid': value.user?.uid,
        'clientType': clientType,
      });

      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      fbUser = await getUserDetails().then((user) {
        Userr().email = user!.email.toString();
        Userr().id = user.uid.toString();
        checkEmailVerified(user);
        return user;
      });


      final instance = FirebaseFirestore.instance.collection('constants');

      await instance.doc("appVersion").get().then((value) {
        appVersion = value.data()!["version"];
      });
    });
    return fbUser;
  } on FirebaseAuthException catch (e) {
    errorCallback(e);
  }
}

Future<User?> getUserDetails() async {
  await FirebaseAuth.instance.currentUser!.reload();
  var user = FirebaseAuth.instance.currentUser;
  fbUser = user;
  return user;
}

Future<bool> registerAccount(String email, String displayName, String password,
    void Function(FirebaseAuthException e) errorCallback) async {
  try {
    var credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await credential.user!.updateDisplayName(displayName).then((value) {
      getUserDetails().then((user) {
        Userr().id = user!.uid.toString();
        Userr().email = user.email.toString();
      });
    });
    return true;
  } on FirebaseAuthException catch (e) {
    errorCallback(e);
    return false;
  }
}

void signOut() {
  FirebaseAuth.instance.signOut();
}
