import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/models/reservation.dart';
import 'package:cork_padel_arena/utils/color_loader.dart';
import 'package:cork_padel_arena/view/reserve.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:interval_time_picker/interval_time_picker.dart' as tPicker;
import 'package:interval_time_picker/models/visible_step.dart';
import 'package:uuid/uuid.dart';


class PermanentReservation extends StatefulWidget {
  const PermanentReservation({Key? key}) : super(key: key);

  @override
  State<PermanentReservation> createState() => _PermanentReservationState();
}

class _PermanentReservationState extends State<PermanentReservation> {
  String? _selectedDay;
  late int weekDayInt;
  String? _selectedDuration;
  String _warning = '';
  TimeOfDay? _timeChosen;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<dynamic> adminReservations = [];
  var uuid = const Uuid();

  @override
  void didChangeDependencies() {
    _warning = AppLocalizations.of(context)!.noTimeChosen;
    super.didChangeDependencies();
  }

  TimeOfDay? value;

  void _presentTimePicker() async {
    final TimeOfDay? newTime = await tPicker
        .showIntervalTimePicker(
      context: context,
      interval: 30,
      visibleStep: VisibleStep.thirtieths,
      initialEntryMode: kIsWeb
          ? tPicker.TimePickerEntryMode.input
          : tPicker.TimePickerEntryMode.dial,
      initialTime: const TimeOfDay(hour: 8, minute: 00),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    )
        .then((newTime) {
      if (newTime != null) {
        setState(() {
          value = newTime;
          _timeChosen = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> dbAdminReservations = firestore
        .collection('adminReservations')
        .snapshots(includeMetadataChanges: true,);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Cork Padel Arena"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.only(top: 20, left: 20),
          height: MediaQuery.of(context).size.height * 0.87,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.adminReservation,
                  style: const TextStyle(
                    fontSize: 28,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade600, width: 2),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                width: MediaQuery.of(context).size.width * 0.90,
                child: Container(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Card(
                            elevation: 3,
                            child: Container(
                              padding:
                              const EdgeInsets.only(left: 10.0, right: 10),
//DROPDOWN LIST TO CHOOSE weekday ////////////////////////////////////////////////
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.weekDay,
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right,
                                  ),
                                  DropdownButton<String>(
                                    alignment: Alignment.centerRight,
                                    isExpanded: false,
                                    hint: Text(AppLocalizations.of(context)!.choose, textAlign: TextAlign.end,),
                                    value: _selectedDay,
                                    items: <String>[
                                      "Segunda",
                                      "Terça",
                                      "Quarta",
                                      "Quinta",
                                      "Sexta",
                                      "Sábado",
                                      "Domingo"
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(
                                            () {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedDay = newValue;
                                              switch(newValue){
                                                case "Segunda":
                                                  weekDayInt = 1;
                                                  break;
                                                case "Terça":
                                                  weekDayInt = 2;
                                                  break;
                                                case "Quarta":
                                                  weekDayInt = 3;
                                                  break;
                                                case "Quinta":
                                                  weekDayInt = 4;
                                                  break;
                                                case "Sexta":
                                                  weekDayInt = 5;
                                                  break;
                                                case "Sábado":
                                                  weekDayInt = 6;
                                                  break;
                                                case "Domingo":
                                                  weekDayInt = 7;
                                                  break;
                                              }
                                            });
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ),
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
                                items: <String>["01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00"]
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
                                          _selectedDuration = newValue;
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
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.only(left: 5.0, right: 5),
                  width: 150,
////////////////////// BUTTON TO RESERVE ////////////////////////////////////////////////
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.reserve,
                        style: const TextStyle(fontSize: 15, letterSpacing: 1),
                      ),
                      onPressed: () async {
                        if(_selectedDuration != null && _selectedDay != null && _timeChosen != null){
                          String _thisDuration = _selectedDuration!;
                          switch (_selectedDuration) {
                            case "01:00":
                              _thisDuration = "60";
                              break;
                            case "01:30":
                              _thisDuration = "90";
                              break;
                            case "02:00":
                              _thisDuration = "120";
                              break;
                            case "02:30":
                              _thisDuration = "150";
                              break;
                            case "03:00":
                              _thisDuration = "180";
                              break;
                            case "03:30":
                              _thisDuration = "210";
                              break;
                            case "04:00":
                              _thisDuration = "240";
                              break;
                            case "04:30":
                              _thisDuration = "270";
                              break;
                            case "05:00":
                              _thisDuration = "300";
                              break;
                          }
                          String until = _thisDuration!;
                          TimeOfDay _until;
                          _until =
                              _timeChosen!.plusMinutes(int.parse(_thisDuration));
                          until =
                          '${_until.hour.toString().padLeft(2, "0")}:${_until.minute.toString().padLeft(2, "0")}';
                          String id = uuid.v4();
                          await (firestore.collection("adminReservations").doc(id).set({
                            "id": id,
                            "weekday": weekDayInt,
                            "day": _selectedDay,
                            "hour":
                            '${_timeChosen!.hour.toString().padLeft(2, "0")}:${_timeChosen!.minute.toString().padLeft(2, "0")}',
                            "duration": until
                          }));
                        }
                      },
                    ),
                  ),
                ),
              ),
////////////////// LIST SHOWING RESERVES FOR THIS DAY ////////////////////////////////////////////////
              StreamBuilder<QuerySnapshot>(
                stream: dbAdminReservations,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ColorLoader();
                  }
                  return snapshot.data!.docs.isNotEmpty
                      ? Expanded(
                        child: ListView(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              return ListTile(
                                leading: const Icon(Icons.lock_clock),
                                title: Text(data['day']),
                                subtitle: Row(
                                  children: [
                                    Text('Das ${data['hour']}'),
                                    Text(' às ${data['duration']}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error,),
                                  onPressed: () {
                                   firestore.collection("adminReservations").doc(data["id"]).delete();
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                      )
                      : const Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text('Sem reservas para mostrar'),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
