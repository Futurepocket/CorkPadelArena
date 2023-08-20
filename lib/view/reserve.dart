import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cork_padel_arena/view/shoppingCart.dart';
import 'package:flutter/foundation.dart';
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
  List<dynamic> adminReservations = [];
  bool today = false;

  @override
  void didChangeDependencies() {
    if(_warning.isEmpty) _warning = AppLocalizations.of(context)!.noTimeChosen;
    super.didChangeDependencies();
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> dbAdminReservations;
  @override
  void initState() {
    dbAdminReservations = firestore
        .collection('adminReservations')
        .snapshots(includeMetadataChanges: true,);
    getClients();
    super.initState();
  }
  void getClients(){
    FirebaseFirestore.instance.collection('users').orderBy('first_name').get().then((users){
      for (var element in users.docs) {
        setState(() {
          clientsEmail.add(element['email']);
          clientsName.add('${element['first_name']} ${element['last_name']} => ${element['email']}');
        });
      }
  });
  }

  //List<Reservation> reservationList = [];

  void validateTime({required String hour, required String duration}){
    String maxTimeText = hour;
    TimeOfDay _startTime = TimeOfDay(
        hour: int.parse(maxTimeText.split(":")[0]),
        minute: int.parse(maxTimeText.split(":")[1]));

    String minTimeText = duration;
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
    }
    TimeOfDay _until;
    if (_timeChosen != null) {
      _until = _timeChosen!.plusMinutes(int.parse(_thisDuration));
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
        return;
      } else if (dbStartTime+0.1 <= pickedEndTime &&
          dbEndTime-0.1 >= pickedEndTime) {
        _reservationValid = false;
        _timeChosen = null;
        _warning = 'Ja existe uma reserva a essa hora!';
        return;
      } else if (pickedStartTime <= dbStartTime+0.1 &&
          dbEndTime-0.1 <= pickedEndTime) {
        _reservationValid = false;
        _timeChosen = null;
        _warning = 'Ja existe uma reserva a essa hora!';
        return;
      } else {
        _reservationValid = true;
      }
    }
  }

  Future<void> _activateListeners() async{
    if(reservationList.isNotEmpty){
      for (var reservation in reservationList) {
        String selectedDay =
        DateFormat('dd/MM/yyyy').format(_selectedDate!);
        String dbDay = reservation.day;
        if (selectedDay == dbDay) {
          validateTime(hour: reservation.hour, duration: reservation.duration);
        } else {
          _reservationValid = true;
        }
      }
    }
    else {
      _reservationValid = true;
    }
    for (var element in adminReservations) {
      if(element["weekday"] == _selectedDate!.weekday){
        validateTime(hour: element["hour"], duration: element["duration"]);
      }
    }
  }

  void _presentDatePicker() {
    _reservationValid = false;
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
    )
        .then((value) {
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
// IF DATA CHOSEN IS AFTER NOW
        if (comparison == 1) {
          setState(() {
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
    var rnd = Random();
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
    String _idd = "${DateFormat('ddMMyyyy').format(_selectedDate!)}$_timeChosen";

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
      floatingActionButton: Badge(
        label: Text(reservationsToCheckOut.length.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
        isLabelVisible: reservationsToCheckOut.isEmpty? false : true,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            showShoppingCart(context).then((value) {
              settingState();
            });
          },
          child: Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.onSecondary),
        ),
      ),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Cork Padel Arena"),
      ),
      body: SingleChildScrollView(
            child: Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.makeReservation,
                      style: const TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  Container(
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
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    padding: const EdgeInsets.only(left: 15, right: 15, top:10),
                    width: MediaQuery.of(context).size.width,
                      child: Column(
                          children: [

/////////////////////////////BUTTON TO CHOOSE DATE////////////////////////////////////////////////
                                  Card(
                                    elevation: 3,
                                    child: ListTile(
                                      leading: const Icon(Icons.calendar_month_outlined),
                                      title: Text(
                                        _selectedDate == null
                                            ? AppLocalizations.of(context)!.noDateChosen
                                            : DateFormat.yMd('pt').format(_selectedDate!),
                                        style: const TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.right,
                                      ),
                                      onTap: (){
                                        _presentDatePicker();
                                      },
                                    ),
                                  ),
////////////////////////////////BUTTON TO CHOOSE TIME ////////////////////////////////////////////////
                            Padding(
                              padding: const EdgeInsets.only(top:8.0),
                              child:
                              Card(
                                elevation: 3,
                                child: ListTile(
                                  leading: const Icon(Icons.watch_later_outlined),
                                  title: Text(
                                    _timeChosen == null
                                        ? _warning
                                        : TimeOfDay(hour: _timeChosen!.hour, minute: _timeChosen!.minute).format(context),
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    textAlign: TextAlign.right,
                                  ),
                                  onTap: _presentTimePicker,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Card(
                                        elevation: 3,
                                        child: Container(
                                          padding:
                                              const EdgeInsets.only(left: 10.0, right: 10),
//DROPDOWN LIST TO CHOOSE DURATION ////////////////////////////////////////////////
                                          child: DropdownButton<String>(
                                            alignment: Alignment.centerRight,
                                            isExpanded: false,
                                            icon: Padding(
                                              padding: const EdgeInsets.only(left: 3.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.timelapse_outlined),
                                                  if(_selectedDuration != null)
                                                  Text(
                                                    AppLocalizations.of(context)!.hours,
                                                    style: const TextStyle(
                                                        fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            hint: Text(AppLocalizations.of(context)!.chooseDuration, textAlign: TextAlign.end,),
                                            value: _selectedDuration,
                                            items: <String>["01:00", "01:30", "02:00"]
                                                .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                alignment: Alignment.centerRight,
                                                child: Text(value),
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
                                      ),

                            ),
                          ],
                        ),
                  ),
                  Text(_warning2),
                  if(Userr().role == "administrador")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(AppLocalizations.of(context)!.reserveAsAnother,
                        style: const TextStyle(
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
                        hint: const Text('Escolha o Cliente'),
                        value: chosenName,
                        items: clientsName.map((String name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(name, style: const TextStyle(fontSize: 14),),
                          );
                        }).toList(),
                        elevation: 3,
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        menuMaxHeight: MediaQuery.of(context).size.height*0.5,
                        dropdownColor: Theme.of(context).colorScheme.surfaceVariant,
                        isExpanded: true,
                        iconSize: 20,
                        onChanged: (value) {
                          int index = clientsName.indexOf(value!);
                          setState(() {
                            chosenName = clientsName[index];
                            chosenClient = clientsEmail[index];
                          });
                        },
                      ),
                  )
                      : Container(),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 150,
////////////////////// BUTTON TO RESERVE ////////////////////////////////////////////////
                      child: ElevatedButton(

                        child: Text(
                          AppLocalizations.of(context)!.reserve,
                          style: const TextStyle(
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
                  if(_selectedDate != null && adminReservations.any((element) => element["weekday"] == _selectedDate!.weekday))
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: Text("Bloqueio de Campo:"),
                    ),
                  StreamBuilder<QuerySnapshot>(
                    stream: dbAdminReservations,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }
                      return (snapshot.data!.docs.isNotEmpty)
                          ? Flexible(
                        flex: 1,
                        child: ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                            if(snapshot.data!.docs.isNotEmpty && !adminReservations.contains(data)){
                              adminReservations.add(data);
                            }
                            if(_selectedDate != null && _selectedDate!.weekday == data["weekday"]){
                              return Container(
                                decoration: const BoxDecoration(color: Color.fromRGBO(255, 0, 0, 0.15),),
                                child: ListTile(
                                  leading: const Icon(Icons.lock_clock),
                                  title: Row(
                                    children: [
                                      Text('Das ${data['hour']}'),
                                      Text(' às ${data['duration']}'),
                                    ],
                                  ),
                                ),
                              );
                            }else{
                              return const SizedBox();
                            }
                          }).toList(),
                        ),
                      )
                          : const SizedBox();
                    },
                  ),
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
                                  leading: const Icon(Icons.timelapse_outlined),
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
                            return Flexible(
                              flex: 7,
                              child: ListView(
                                children: tilesList,
                              )
                            );
                          }
                          return Text(AppLocalizations.of(context)!.noReservationsOnDay);
                        })
                      : const SizedBox(),
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
  const ToastWidget({Key? key}) : super(key: key);

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
          child: const Padding(
            padding: EdgeInsets.all(5.0),
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
