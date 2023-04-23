import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dash.dart';
import 'editDetails.dart';
import 'new_my_Reservations.dart';
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

  settingState() {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
        newSnackBar(context,
            const Text('Perfil atualizado com sucesso.')));
  }

  Userr _userr = Userr();
  static const double _padd = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myProfile),
      ),
      body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        bottom: kIsWeb? 580 : 850,
                        child: CircleAvatar(
                            radius: 400,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const CircleAvatar(
                            radius: 398,
                            backgroundColor: Colors.white,
                          ),
                          ),
                      ),
                      Positioned(
                        top: 10,
                        child: Text(
                          '${_userr.name} ${_userr.surname}',
                          style: const TextStyle(
                            fontFamily: 'Roboto Condensed',
                            fontSize: 28,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: CircleAvatar(
                                radius: 33,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            ),
                          ),
                      Positioned(
                        top: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(20),
                            child: Wrap(
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey))
                                  ),
                                  child: ListTile(
                                      leading: const Icon(Icons.person),
                                      title: Text(
                                        '${_userr.name} ${_userr.surname}',
                                        style: const TextStyle(fontSize: 16),
                                      )
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey))
                                  ),
                                  child: ListTile(
                                      leading: const Icon(Icons.alternate_email),
                                      title: Text(
                                        _userr.email,
                                        style: const TextStyle(fontSize: 16),
                                      )
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey))
                                  ),
                                  child: ListTile(
                                      leading: const Icon(Icons.phone),
                                      title: Text(
                                        _userr.phoneNbr,
                                        style: const TextStyle(fontSize: 16),
                                      )
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey))
                                  ),
                                  child: ListTile(
                                      leading: const Icon(Icons.place_outlined),
                                      title: Text(
                                        _userr.address,
                                        style: const TextStyle(fontSize: 16),
                                      )
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey))
                                  ),
                                  child: ListTile(
                                      leading: const Icon(Icons.numbers),
                                      title: Text(
                                        _userr.postCode,
                                        style: const TextStyle(fontSize: 16),
                                      )
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey))
                                  ),
                                  child: ListTile(
                                      leading: const Icon(Icons.location_city_outlined),
                                      title: Text(
                                        _userr.city,
                                        style: const TextStyle(fontSize: 16),
                                      )
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey))
                                  ),
                                  child: ListTile(
                                      leading: const Icon(Icons.account_balance_outlined),
                                      title: Text(
                                        _userr.nif,
                                        style: const TextStyle(fontSize: 16),
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 500,
                        child: Container(
                          padding: const EdgeInsets.only(top: 15, right: 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.editProfile,
                              style: const TextStyle(fontSize: 15, letterSpacing: 1.2),
                            ),
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).push(MaterialPageRoute(builder: (_) {
                                return EditDetails(settingState: settingState,);
                              }));
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),

              ],
            ),
          ),

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(children: [
        FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            showShoppingCart(context).then((value) {
              settingState();
            });
          },
          child: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
        ),
        reservationsToCheckOut.isEmpty
            ? Positioned(top: 1.0, left: 1.0, child: Container())
            : Positioned(
                top: 1.0,
                left: 1.0,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    reservationsToCheckOut.length.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
      ]),
    );
  }
}
