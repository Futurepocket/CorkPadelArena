// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:table_calendar/table_calendar.dart';

import '../view/new_admin_reservations.dart';


/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kReservations = LinkedHashMap<DateTime, List<Reservation>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(calendarMap);


// final _kReservationSource = {
//   for (var reservation in reservationList)
//     DateTime.utc(formatter.parse(reservation.day).year, formatter.parse(reservation.day).month, formatter.parse(reservation.day).day) : reservationList.where((element) => element.day == reservation.day).toList()
//   };

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
        (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);