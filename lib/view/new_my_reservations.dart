// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/utils/calendar_utils.dart';
import 'package:cork_padel_arena/view/dash.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/userr.dart';
import '../src/widgets.dart';
import '../utils/color_loader.dart';
Map<DateTime, List<Reservation>> calendarMap = {};
class NewMyReservations extends StatefulWidget {
  @override
  _NewMyReservationsState createState() => _NewMyReservationsState();
}

class _NewMyReservationsState extends State<NewMyReservations> {
  late final PageController _pageController;
  late final ValueNotifier<List<Reservation>> _selectedReservations;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime? _selectedDay;
  var today = DateTime.now();

  @override
  void initState() {
    _groupReservations(today);
    super.initState();

  }
  LinkedHashMap? kReservations;
  void _groupReservations(today){
    final formatter = DateFormat('dd/MM/yyyy');
    DatabaseReference database = FirebaseDatabase.instance.ref('reservations');
    database.onValue.listen((event) {
      if(event.snapshot.value != null){
        final reservationMap = Map<String, dynamic>.from(event.snapshot.value as dynamic);
        reservationList = reservationMap.entries.map((e) {
          return Reservation.fromRTDB(Map<String, dynamic>.from(e.value));
        }).toList();
        reservationList.removeWhere((element) => element.userEmail != Userr().email);
        var newMap = reservationList.groupListsBy((element) => DateTime.utc(formatter.parse(element.day).year, formatter.parse(element.day).month, formatter.parse(element.day).day));
        setState(() {
          calendarMap = newMap;
        });

        kReservations = LinkedHashMap<DateTime, List<Reservation>>(
          equals: isSameDay,
          hashCode: getHashCode,
        )..addAll(calendarMap);
        _getReservationsForDay(today);
        _selectedReservations = ValueNotifier(_getReservationsForDay(_focusedDay));
      }
    });
  }

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
  @override
  void dispose() {
    _selectedReservations.dispose();
    super.dispose();
  }

  List<Reservation> _getReservationsForDay(DateTime day) {
    return kReservations![day] ?? [];
  }



  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedReservations.value = _getReservationsForDay(selectedDay);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Reservas'),
      ),
      body: kReservations == null? Center(child: ColorLoader(),) :Column(
        children: [
          TableCalendar<Reservation>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            headerVisible: true,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            locale: 'pt_PT',
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getReservationsForDay,
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: const Color.fromRGBO(212, 207, 96, 0.7),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            onCalendarCreated: (controller) => _pageController = controller,
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
          ),
          Container(height: 8.0,
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1
                  ),)
            ),),
          Expanded(
            child: ValueListenableBuilder<List<Reservation>>(
              valueListenable: _selectedReservations,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 2.0,
                      ),
                      child: Card(
                        elevation: 5,
                        child: ListTile(
                          leading: Icon(Icons.timelapse),
                          title: Text(value[index].userEmail),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dia ${value[index].day} Das ${value[index].hour} às ${value[index].duration}'),
                              value[index].completed == false? Text('No carrinho do utilizador', style: TextStyle(color: Colors.red, fontSize: 10),)
                                  :Container()
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  void _deleting(BuildContext context, String id) {
    final _database =
    FirebaseDatabase.instance.ref().child('reservations').child(id);
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(fontSize: 24),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.sureToCancelReservation,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              StyledButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  AppLocalizations.of(context)!.doNotCancel,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                background: Colors.white,
                border: Theme.of(context).colorScheme.primary,
              ),
              StyledButton(
                onPressed: () {
                  _database.remove();
                  Navigator.of(context).pop(true);
                  setState(() {
                    _selectedDay = null;
                  });

                },
                child: Text(
                  AppLocalizations.of(context)!.yesCancel,
                  style: const TextStyle(color: Colors.white),
                ),
                background: Colors.red,
                border: Colors.red,
              ),
            ],
          );
        });
  }
}
