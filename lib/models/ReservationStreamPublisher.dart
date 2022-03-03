import 'package:cork_padel_arena/models/reservation.dart';
import 'package:firebase_database/firebase_database.dart';

import '../view/dash.dart';


class ReservationStreamPublisher {
  FirebaseDatabase data = FirebaseDatabase.instance;

  Stream<List<Reservation>> getReservationStream() {
    DatabaseReference database = data.ref();
    final stream = database.child('reservations').orderByChild('day').onValue;
    final streamToPublish = stream
        .map((event) {
          final reservationMap = Map<String, dynamic>.from(event.snapshot.value as dynamic);
      reservationList = reservationMap.entries.map((e) {
        return Reservation.fromRTDB(Map<String, dynamic>.from(e.value));
      }).toList();
      return reservationList;
    });
    return streamToPublish;
  }
}
