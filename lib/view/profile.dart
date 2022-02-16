import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'dash.dart';
import 'editDetails.dart';
import 'myReservations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  checkoutValue _check = checkoutValue();
  @override
  void initState() {
    super.initState();
  }
  settingState(){
    setState(() {

    });
  }
  Userr _userr = Userr();
  static const double _padd = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Align(
              alignment: Alignment.centerLeft,
              child: Text("Cork Padel Arena")),
          backgroundColor: Theme.of(context).primaryColor),
      body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left:20.0, top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(
                AppLocalizations.of(context)!.myProfile,
                style: TextStyle(
                  fontFamily: 'Roboto Condensed',
                  fontSize: 16,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Text(
                AppLocalizations.of(context)!.personalDetails,
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
              ))),),
              Container(
                padding:
                    EdgeInsets.only(top: 20, right: 15, bottom: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Card(elevation: 5,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Nome: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              _userr.name + ' ' + _userr.surname,
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: _padd),
                          child: Row(children: [
                            Text(
                              "Email: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              _userr.email,
                              style: TextStyle(fontSize: 16),
                            )
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: _padd),
                          child: Row(children: [
                            Text(
                              "Tel: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              _userr.phoneNbr,
                              style: TextStyle(fontSize: 16),
                            )
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: _padd),
                          child: Row(
                            children: [
                              Text(
                                "Morada: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(
                                width: 220,
                                child: Text(
                                  _userr.address,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: _padd),
                          child: Row(children: [
                            Text(
                              "Codigo Postal: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              _userr.postCode,
                              style: TextStyle(fontSize: 16),
                            )
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: _padd),
                          child: Row(children: [
                            Text(
                              "Localidade: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              _userr.city,
                              style: TextStyle(fontSize: 16),
                            )
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: _padd),
                          child: Row(children: [
                            Text(
                              "NIF: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              _userr.nif,
                              style: TextStyle(fontSize: 16),
                            )
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 15, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          onPrimary: Colors.white,
                        ),
                        child: Text(
                          "EDITAR PERFIL",
                          style: TextStyle(fontSize: 15, letterSpacing: 1.2),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (_) {
                            return EditDetails();
                          })).then((value) {
                            settingState();
                            ScaffoldMessenger.of(context).showSnackBar(
                                newSnackBar(context, Text('Perfil atualizado com sucesso.')));
                          });
                        },
                      ),
                    ),
                    Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          onPrimary: Colors.white,
                        ),
                        child: Text(
                          "MINHAS RESERVAS",
                          style: TextStyle(fontSize: 15,),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (_) {
                            return MyReservations();
                          }));
                        },
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
            ),
    ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(
          children: [
            FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
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
    );
  }
}
