import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/src/widgets.dart';
import 'package:cork_padel_arena/view/reserve.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

List<Reservation> reservationList = [];
List<Reservation> reservationsToCheckOut = [];

Future<void> currentUser() {
  final user = FirebaseAuth.instance.currentUser;
  final String _email = user!.email.toString();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(_email)
      .get()
      .then((value) {
    Userr().name = value.data()!["first_name"].toString();
    Userr().email = value.data()!["email"].toString();
    Userr().address = value.data()!["address"].toString();
    Userr().surname = value.data()!["last_name"].toString();
    Userr().city = value.data()!["city"].toString();
    Userr().id = value.data()!["id"].toString();
    Userr().nif = value.data()!["nif"].toString();
    Userr().postCode = value.data()!["postal_code"].toString();
    Userr().role = value.data()!["role"].toString();
  });
}

void showToast({
  required BuildContext context,
}) {
  OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(builder: (context) => ToastWidget());
  Overlay.of(context)!.insert(overlayEntry);
  Timer(Duration(seconds: 4), () => overlayEntry.remove());
}

SnackBar newSnackBar(BuildContext context, Text content) {
  return SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 6.0,
      content: content);
}

void showErrorDialog(BuildContext context, String title, Exception e) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 24),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                '${(e as dynamic).message}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          StyledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child:  Text(
              'OK',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      );
    },
  );
}