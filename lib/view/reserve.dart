import 'dart:async';
import 'dart:math';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cork_padel_arena/models/ReservationStreamPublisher.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/view/shoppingCart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Reserve extends StatefulWidget {
  @override
  _ReserveState createState() => _ReserveState();
}

void showToast({
  required BuildContext context,
}) {
  OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(builder: (context) => ToastWidget());
  Overlay.of(context)!.insert(overlayEntry);
  Timer(Duration(seconds: 4), () => overlayEntry.remove());
}

class _ReserveState extends State<Reserve> {
  checkoutValue _check = checkoutValue();

  DatabaseReference database = FirebaseDatabase.instance.ref();
  String? _selectedDuration;
  String _warning = '';
  String _warning2 = '';

  DateTime? _selectedDate;
  TimeOfDay? _timeChosen;
  bool _reservationValid = false;
  bool _isNotNow = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _warning = AppLocalizations.of(context)!.noTimeChosen;
    super.didChangeDependencies();
  }
  @override
  void initState() {
    super.initState();

  }
  //List<Reservation> reservationList = [];

  void _activateListeners(){
    if(reservationList.isNotEmpty){
      for (var reservation in reservationList) {
        String selectedDay =
        DateFormat('dd/MM/yyyy').format(_selectedDate!);
        String dbDay = reservation.day;
        print('dbDay: ${dbDay}');
        print('dbDay: ${selectedDay}');
        print('selDay: ${selectedDay}');
        print('dbDay: ${dbDay}');
        if (selectedDay == dbDay) {
          String maxTimeText = reservation.hour;
          TimeOfDay _startTime = TimeOfDay(
              hour: int.parse(maxTimeText.split(":")[0]),
              minute: int.parse(maxTimeText.split(":")[1]));

          String minTimeText = reservation.duration;
          TimeOfDay _endTime = TimeOfDay(
              hour: int.parse(minTimeText.split(":")[0]),
              minute: int.parse(minTimeText.split(":")[1]));

          TimeOfDay _until;
          if (_timeChosen != null) {
            _until =
                _timeChosen!.plusMinutes(int.parse(_selectedDuration!));

            double dbStartTime = toDouble(_startTime);
            double dbEndTime = toDouble(_endTime);
            double pickedStartTime = toDouble(_timeChosen!);
            double pickedEndTime = toDouble(_until);

            if (dbStartTime <= pickedStartTime &&
                dbEndTime >= pickedStartTime) {
              _reservationValid = false;
              _timeChosen = null;
              _warning = 'Ja existe uma reserva a essa hora!';
            } else if (dbStartTime <= pickedEndTime &&
                dbEndTime >= pickedEndTime) {
              _reservationValid = false;
              _timeChosen = null;
              _warning = 'Ja existe uma reserva a essa hora!';
            } else if (pickedStartTime <= dbStartTime &&
                dbEndTime <= pickedEndTime) {
              _reservationValid = false;
              _timeChosen = null;
              _warning = 'Ja existe uma reserva a essa hora!';
            } else {
              _reservationValid = true;
            }
          }
        } else {
          _reservationValid = true;
        }
      }
    }
    else {
      _reservationValid = true;
    }

  }

  void _presentDatePicker() {
    _reservationValid = false;
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 365)),
    )
        .then((value) {
      print(value);
      if (value == null) {
        return;
      }
      setState(() {
        _selectedDate = value;
        _timeChosen = null;
        _warning = 'Nenuma Hora Escolhida!';
      });
    });
  }

  void _presentTimePicker() {
    _reservationValid = false;
    var date = DateTime.now();
    showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay(hour: 8, minute: 00),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    ).then((value) {
      if (value == null) {
        return;
      } else {
        if (_selectedDate != null) {
          var pickedTime = DateTime(_selectedDate!.year, _selectedDate!.month,
              _selectedDate!.day, value.hour, value.minute);
//COMPARING PICKED DATE WITH DATE NOW
          var comparison = pickedTime.compareTo(date);
print(comparison);
// IF DATA CHOSEN IS AFTER NOW
          if (comparison == 1) {
            setState(() {
              _timeChosen = value;
              _isNotNow = true;
              if (_selectedDuration != null) _activateListeners();
            });
//IF DATE CHOSEN IS NOW OR BEFORE
          } else {
            setState(() {
              _timeChosen = null;
              _warning = 'Nao pode fazer reservas no passado';
              _isNotNow = true;
            });
          }
        } else {
//IF DAY IS NOT CHOSEN YET
          setState(() {
            _timeChosen = null;
            _warning = 'Escolha o Dia Primeiro';
          });
        }
      }
    });
  }

  String randomNumbers() {
    var rndnumber = "";
    var rnd = new Random();
    for (num i = 1; i < 7; i++) {
      rndnumber = rndnumber + (rnd.nextInt(9) + 1).toString();
    }
    String number = num.parse(rndnumber).toString();
    return number;
  }
  settingState(){
    setState(() {

    });
  }

  var tempReservations = <Reservation>[];
  var days = <String>[];

  void _reserve() async {
    final reservations = database.child('reservations');
    String _pin = randomNumbers();
    String _idd = DateFormat('ddMMyyyy').format(_selectedDate!) +
        "${_timeChosen!.format(context)}";

    final day = reservations.child(_idd);
    String until = _selectedDuration!;
    TimeOfDay _until;
    _until = _timeChosen!.plusMinutes(int.parse(_selectedDuration!));
    until = _until.format(context);

    Reservation _reservation = Reservation(
        pin: _pin,
        day: DateFormat('dd/MM/yyyy').format(_selectedDate!),
        hour: _timeChosen!.format(context),
        duration: until,
        state: 'por completar',
        userEmail: Userr().email,
        completed: false,
        id: _idd,
        dateMade: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        timeMade: DateFormat('HH:mm').format(DateTime.now()));
    setState(() {
      reservationsToCheckOut.add(_reservation);
      _check.reservations = reservationsToCheckOut.length;
      _check.price = _check.reservations * 10;
    });
    try {
      //await reservations.set(_reservation);
      await day.set({
        'pin': _reservation.pin,
        'id': _reservation.id,
        'day': _reservation.day,
        'hour': _reservation.hour,
        'duration': _reservation.duration,
        'state': _reservation.state,
        'client_email': _reservation.userEmail,
        'completed': _reservation.completed,
        'dateMade': _reservation.dateMade,
        'timeMade': _reservation.timeMade,
      });
    } catch (e) {
      print('There is an error!');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: shopCart(context, settingState),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Cork Padel Arena"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 40, left: 20),
            constraints: BoxConstraints(
                minHeight: 600, minWidth: double.infinity, maxHeight: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.reservations,
                  style: TextStyle(
                    fontFamily: 'Roboto Condensed',
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: Text(
                    AppLocalizations.of(context)!.makeReservation,
                    style: TextStyle(
                      fontFamily: 'Roboto Condensed',
                      fontSize: 28,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.9,
                  height: 20,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.grey.shade600,
                              width: 2
                          ),
                      ),
                  ),
                ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      AppLocalizations.of(context)!.attention30Mins,
                      style: TextStyle(
                        fontFamily: 'Roboto Condensed',
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  width: MediaQuery.of(context).size.width*0.90,
                  child: Card(
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top:10),
                      child: Column(
                        children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
/////////////////////////////BUTTON TO CHOOSE DATE////////////////////////////////////////////////
                              Container(
                                width: 110,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _presentDatePicker();
                                  },
                                  child: FittedBox(
                                    child: Text(AppLocalizations.of(context)!
                                        .chooseDate,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                            fontSize: 12,
                                          letterSpacing: 1
                                        ),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
/////////////////////////////TEXT SHOWING CHOSEN DATE////////////////////////////////////////////////
                                Container(
                                  width: 180,
                                  child: Text(
                                    _selectedDate == null
                                        ? AppLocalizations.of(context)!.noDateChosen
                                        : '${DateFormat.yMd('pt').format(_selectedDate!)}',
                                    style: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right,
                                  ),
                                ),

                            ]),
                          Padding(
                            padding: const EdgeInsets.only(top:8.0),
                            child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
////////////////////////////////BUTTON TO CHOOSE TIME ////////////////////////////////////////////////
                                    Container(
                                      width: 110,
                                      child: ElevatedButton(
                                        onPressed: _presentTimePicker,
                                        child: FittedBox(
                                          child: Text(AppLocalizations.of(context)!
                                              .chooseTime,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 1,
                                                fontSize: 12
                                              )),
                                        ),
                                        style: TextButton.styleFrom(
                                          primary: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
/////////////////////////////////TEXT SHOWING CHOSEN TIME ////////////////////////////////////////////////

                                 Container(
                                   width: 180,
                                     child: Text(
                                            _timeChosen == null
                                                ? _warning
                                                : '${_timeChosen!.format(context)}',
                                            style: TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.bold),
                                       maxLines: 2,
                                       textAlign: TextAlign.right,
                                          ),

                                 ),



                              ],
                              ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    '${AppLocalizations.of(context)!.duration}:',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.only(left: 5.0, right: 5),
                                    width: 120,
//DROPDOWN LIST TO CHOOSE DURATION ////////////////////////////////////////////////
                                    child: DropdownButton<String>(
                                      hint: Text(AppLocalizations.of(context)!.choose),
                                      value: _selectedDuration,
                                      items: <String>['30', '60', '90', '120']
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: new Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(
                                          () {
                                            if (_timeChosen != null) {
                                              setState(() {
                                                _warning2 = '';
                                                _reservationValid = false;
                                                _selectedDuration = newValue;
                                                _activateListeners();
                                              });
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.minutes,
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(_warning2),

            Container(
              width: MediaQuery.of(context).size.width*0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Container(
                  padding: const EdgeInsets.only(left: 5.0, right: 5),
                  width: 150,
////////////////////// BUTTON TO RESERVE ////////////////////////////////////////////////
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.reserve,
                      style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 1),
                    ),
                    onPressed: () {
                      if (_reservationValid &&
                          _isNotNow &&
                          _selectedDuration != null) {
                        _reserve();
                        showToast(context: context);
                        return;
                      } else if (!_reservationValid || !_isNotNow) {
                        _timeChosen = null;
                        _warning = AppLocalizations.of(context)!.invalidSlot;
                        setState(() {
                          _warning2 = AppLocalizations.of(context)!.invalidSlot;
                        });
                        return;
                      } else if (_selectedDuration == null) {
                        setState(() {
                          _warning2 = AppLocalizations.of(context)!.chooseDuration;
                        });
                        return;
                      }
                    },
                  ),
                ),
////////////////// LIST SHOWING RESERVES FOR THIS DAY ////////////////////////////////////////////////
                if(_selectedDate !=null )Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: Text('${AppLocalizations.of(context)!.reservedSlots}:'),
                ),
                _selectedDate != null
                    ? Container(
                  width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height*0.3,
                      padding: const EdgeInsets.only(top:8.0),
                      child: StreamBuilder(
                      stream:
                      ReservationStreamPublisher().getReservationStream(),
                      builder: (context, snapshot) {
                        final tilesList = <ListTile>[];
                        if (snapshot.hasData) {
                          List reservations =
                          snapshot.data as List<Reservation>;
                          int i = 0;
                          do {
                            if (reservations.isNotEmpty) {
                              if (reservations[i].day !=
                                  (DateFormat('dd/MM/yyyy')
                                      .format(_selectedDate!))) {
                                reservations.removeAt(i);
                                i = i;
                              } else
                                i++;
                            }
                          } while (i < reservations.length);
                          try {
                            tilesList
                                .addAll(reservations.map((nextReservation) {
                              return ListTile(
                                leading: Icon(Icons.lock_clock),
                                title: Text(
                                    "${AppLocalizations.of(context)!.from} ${nextReservation.hour} ${AppLocalizations.of(context)!.to} ${nextReservation.duration}"),
                              );
                            }));
                          } catch (e) {
                            return Text(
                                AppLocalizations.of(context)!.noReservationsOnDay);
                          }
                        }
                        // }
                        if (tilesList.isNotEmpty) {
                          return Expanded(
                            child: ListView(
                              children: tilesList,
                            ),
                          );
                        }
                        return Text(AppLocalizations.of(context)!.noReservationsOnDay);
                      }),
                )
                    : SizedBox(),
              ],),
            ),

              ],
            ),
          ),
        ),
    );
  }
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay plusMinutes(int minutes) {
    if (minutes == 0) {
      return this;
    } else {
      int mofd = this.hour * 60 + this.minute;
      int newMofd = ((minutes % 1440) + mofd + 1440) % 1440;
      if (mofd == newMofd) {
        return this;
      } else {
        int newHour = newMofd ~/ 60;
        int newMinute = newMofd % 60;
        return TimeOfDay(hour: newHour, minute: newMinute);
      }
    }
  }
}

double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

class ToastWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.0,
      width: MediaQuery.of(context).size.width - 20,
      left: 10,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Material(
          color: Theme.of(context).primaryColor,
          elevation: 10.0,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              'Reserva adicionada ao carrinho',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
