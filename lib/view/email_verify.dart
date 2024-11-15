import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/constants/constants.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/firebase_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailVerify extends StatefulWidget {

  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  Timer? timer;

  startTimer(){
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {checkEmail();});
  }

  void checkEmail(){
    getUserDetails().then((user) {
      checkEmailVerified(user!).then((value) {
        if (value == true) {
          final String _email = fbUser!.email.toString();
          FirebaseFirestore.instance
              .collection(userCollection)
              .doc(_email).get().then((value) {
            if(value.exists){
              Navigator.of(context).pushReplacementNamed('/dash');
            }
            else {
              Navigator.of(context).pushReplacementNamed(
                  '/userDetails');
            }
          });
          timer!.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Cork Padel"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 80),
        child: Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
          Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Image.asset(
            'assets/images/logo.png',
            width: 80.0,
            height: 100.0,
          ),
        ),
        Column(
          children: [
            Text(
              '${AppLocalizations.of(context)!.signIn} ${Userr().email}. ${AppLocalizations.of(context)!.pleaseVisitMailBox}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              '\n${AppLocalizations.of(context)!.didNotReceive}\n',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18,
                color: Theme.of(context).primaryColor,),
            ),
            Container(
              width: 150,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.resend,
                    style: const TextStyle(fontSize: 15),
                  ),
                  onPressed: () {
                    fbUser!.sendEmailVerification();
                  }),
            )
          ],
        ),
              ]
          ),
        ),
      ),

    );
  }
}