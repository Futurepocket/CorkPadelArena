import 'package:cork_padel_arena/models/userr.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:async';

Future<void> init() async {

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
bool emailVerified = false;



void checkEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
    ) async {
  try {
    var methods =
    await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
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

Future<void> checkEmailVerified() async {
  if (fbUser!.emailVerified) {
    emailVerified = true;
  } else {
    emailVerified = false;
  }
}

Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
    ) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    fbUser = FirebaseAuth.instance.currentUser;
    Userr().email = fbUser!.email.toString();
    checkEmailVerified();
    return fbUser;
  } on FirebaseAuthException catch (e) {
    errorCallback(e);
  }
  FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
}

void getUserDetails() async {
  fbUser = FirebaseAuth.instance.currentUser;
  Userr().id = fbUser!.uid.toString();
  Userr().email = fbUser!.email.toString();
}




void registerAccount(String email, String displayName, String password,
    void Function(FirebaseAuthException e) errorCallback) async {
  try {
    var credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await credential.user!.updateDisplayName(displayName);
    final User? user = credential.user;
    fbUser = FirebaseAuth.instance.currentUser;
    fbUser!.sendEmailVerification();
    Userr().id = user!.uid.toString();
    Userr().email = user.email.toString();
  } on FirebaseAuthException catch (e) {
    errorCallback(e);
  }
}

void signOut() {
  FirebaseAuth.instance.signOut();
}

