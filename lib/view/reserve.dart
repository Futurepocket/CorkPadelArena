import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/view/shoppingCart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cork_padel_arena/models/ReservationStreamPublisher.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:interval_time_picker/interval_time_picker.dart' as tPicker;
import 'dash.dart';
class Reserve extends StatefulWidget {
  @override
  _ReserveState createState() => _ReserveState();
}

class _ReserveState extends State<Reserve> {

  DatabaseReference database = FirebaseDatabase.instance.ref();
  String? _selectedDuration;
  String _warning = '';
  String _warning2 = '';
  DateTime? _selectedDate;
  TimeOfDay? _timeChosen;
  TimeOfDay? value;
  bool _reservationValid = false;
  bool _isNotNow = false;
  bool _asAnother = false;
  String? chosenClient;
  String? chosenName;
  List<String> clientsEmail = [];
  List<String> clientsName = [];

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _warning = AppLocalizations.of(context)!.noTimeChosen;
    super.didChangeDependencies();
  }
  @override
  void initState() {
    getClients();
    super.initState();
  }
  void getClients(){
    FirebaseFirestore.instance.collection('users').orderBy('first_name').get().then((users){
      users.docs.forEach((element) {
        setState(() {
          clientsEmail.add(element['email']);
          clientsName.add('${element['first_name']} ${element['last_name']} => ${element['email']}');
        });
      });
  });
  }

  //List<Reservation> reservationList = [];

  Future<void> _activateListeners() async{
    if(reservationList.isNotEmpty){
      for (var reservation in reservationList) {
        String selectedDay =
        DateFormat('dd/MM/yyyy').format(_selectedDate!);
        String dbDay = reservation.day;
        if (selectedDay == dbDay) {
          String maxTimeText = reservation.hour;
          TimeOfDay _startTime = TimeOfDay(
              hour: int.parse(maxTimeText.split(":")[0]),
              minute: int.parse(maxTimeText.split(":")[1]));

          String minTimeText = reservation.duration;
          TimeOfDay _endTime = TimeOfDay(
              hour: int.parse(minTimeText.split(":")[0]),
              minute: int.parse(minTimeText.split(":")[1]));
          String _thisDuration = _selectedDuration!;
          switch(_selectedDuration){
            case "01:00":
              _thisDuration = "60";
              break;
            case "01:30":
              _thisDuration = "90";
              break;
            case "02:00":
              _thisDuration = "120";
              break;
            default:
              break;
          }
          TimeOfDay _until;
          if (_timeChosen != null) {
            _until = _timeChosen!.plusMinutes(int.parse(_thisDuration));
            print(_until);
            double dbStartTime = toDouble(_startTime);
            double dbEndTime = toDouble(_endTime);
            double pickedStartTime = toDouble(_timeChosen!);
            double pickedEndTime = toDouble(_until);
            if(dbEndTime == 0.0){
              dbEndTime = 24.0;
            }
            if(dbEndTime == 0.5){
              dbEndTime = 24.5;
            }

            if (dbStartTime+0.1 <= pickedStartTime &&
                dbEndTime-0.1 >= pickedStartTime) {
              _reservationValid = false;
              _timeChosen = null;

              _warning = 'Ja existe uma reserva a essa hora!';
            } else if (dbStartTime+0.1 <= pickedEndTime &&
                dbEndTime-0.1 >= pickedEndTime) {
              _reservationValid = false;
              _timeChosen = null;
              _warning = 'Ja existe uma reserva a essa hora!';

            } else if (pickedStartTime <= dbStartTime+0.1 &&
                dbEndTime-0.1 <= pickedEndTime) {
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

  void _presentTimePicker() async {
   final TimeOfDay? newTime = await tPicker.showIntervalTimePicker(
      context: context,
      interval: 30,
      visibleStep: tPicker.VisibleStep.thirtieths,
      initialEntryMode: kIsWeb? tPicker.TimePickerEntryMode.input :tPicker.TimePickerEntryMode.dial,
      initialTime: const TimeOfDay(hour: 8, minute: 00),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
     ).then((newTime) {
     if (newTime != null) {
       setState(() {
         value = newTime;
         setTime(value);
       });
     }
   });
  }

  void setTime(value){
    _reservationValid = false;
    var date = DateTime.now();
    if (value == null) {
      return;
    } else {
      if (_selectedDate != null) {
        var pickedTime = DateTime(_selectedDate!.year, _selectedDate!.month,
            _selectedDate!.day, value.hour, value.minute);
//COMPARING PICKED DATE WITH DATE NOW
        var comparison = pickedTime.compareTo(date);
        print('When $comparison');
// IF DATA CHOSEN IS AFTER NOW
        if (comparison == 1) {
          setState(() {
            print(value);
            _timeChosen = value;
            _isNotNow = true;
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
        "$_timeChosen";

    String? price;
    String _thisDuration = _selectedDuration!;
    switch(_selectedDuration){
      case "01:00":
        _thisDuration = "60";
        break;
      case "01:30":
        _thisDuration = "90";
        break;
      case "02:00":
        _thisDuration = "120";
        break;
      default:
        break;
    }
 switch(_thisDuration){
   case "60":
     price = "24";
     break;
   case "90":
     price = "29";
     break;
   case "120":
     price = "39";
     break;
   default:
     break;
    }
    final day = reservations.child(_idd);
    String until = _thisDuration;
    TimeOfDay _until;
    _until = _timeChosen!.plusMinutes(int.parse(_thisDuration));
    until = '${_until.hour.toString().padLeft(2, "0")}:${_until.minute.toString().padLeft(2, "0")}';

    Reservation _reservation = Reservation(
        pin: _pin,
        day: DateFormat('dd/MM/yyyy').format(_selectedDate!),
        hour: '${_timeChosen!.hour.toString().padLeft(2, "0")}:${_timeChosen!.minute.toString().padLeft(2, "0")}',
        duration: until,
        state: 'por completar',
        userEmail: (chosenClient==null || !_asAnother)? Userr().email
        : chosenClient!,
        completed: false,
        id: _idd,
        price: price!,
        dateMade: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        timeMade: DateFormat('HH:mm').format(DateTime.now()));
    setState(() {
      reservationsToCheckOut.add(_reservation);
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
        'price': _reservation.price,
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
      floatingActionButton: Stack(
          children: [
            FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                ShoppingCart().createState().build(context);
                showShoppingCart(context).then((value) {
                  settingState();
                });
              },
              child: Icon(Icons.shopping_cart, color: Colors.white,),
            ),

            reservationsToCheckOut.isEmpty?
            Positioned(
                top: 1.0,
                left: 1.0,
                child: Container())
                : Positioned(
              top: 1.0,
              left: 1.0,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(reservationsToCheckOut.length.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),
            )
          ]
      ),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Cork Padel Arena"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 20, left: 20),
           height: MediaQuery.of(context).size.height*0.87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.reservations,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: Text(
                    AppLocalizations.of(context)!.makeReservation,
                    style: TextStyle(
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
                    padding: const EdgeInsets.only(top: 20.0, right:10),
                    child: Text(
                      AppLocalizations.of(context)!.attention30Mins,
                      style: TextStyle(
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
                                                : TimeOfDay(hour: _timeChosen!.hour, minute: _timeChosen!.minute).format(context),
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
                                      items: <String>["01:00", "01:30", "02:00"]
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
                                    AppLocalizations.of(context)!.hours,
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
                if(Userr().role == "administrador")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(AppLocalizations.of(context)!.reserveAsAnother,
                      style: TextStyle(
                      fontSize: 16,
                    ),),
                    Switch(
                        value: _asAnother,
                        onChanged: (_) => setState(() {
                          _asAnother = !_asAnother;
                        }))
                  ],
                ),
                _asAnother?
                Align(
                  alignment: Alignment.center,
                  child: DropdownButton<String>(
                      hint: Text('Escolha o Cliente'),
                      value: chosenName,
                      items: clientsName.map((String name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name, style: TextStyle(fontSize: 14),),
                        );
                      }).toList(),
                      onChanged: (value) {
                        int index = clientsName.indexOf(value!);
                        setState(() {
                          chosenName = clientsName[index];
                          chosenClient = clientsEmail[index];
                          print(chosenClient);
                        });
                      },
                    ),
                )
                    : Container(),
                Align(
                  alignment: Alignment.center,
                  child: Container(
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
                      onPressed: () async{
                        _activateListeners().then((_){
                          if (_reservationValid &&
                              _isNotNow &&
                              _selectedDuration != null) {
                            _reserve();
                            ScaffoldMessenger.of(context).showSnackBar(
                                newSnackBar(context,
                                    Text(AppLocalizations.of(context)!.reservationAdded))
                            );
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
                        });

                      },
                    ),
                  ),
                ),
////////////////// LIST SHOWING RESERVES FOR THIS DAY ////////////////////////////////////////////////
                if(_selectedDate !=null )Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: Text('${AppLocalizations.of(context)!.reservedSlots}:'),
                ),
                _selectedDate != null
                    ? StreamBuilder(
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
                      })
                    : SizedBox(),
              ],),
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
            padding: const EdgeInsets.all(5.0),
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
