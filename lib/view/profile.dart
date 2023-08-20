import 'package:cork_padel_arena/main.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/models/splitScaffoldBody.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dash.dart';
import 'editDetails.dart';
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
            child: SizedBox(
              height: MediaQuery.of(context).size.height-100,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: -700, //: 850,
                          child: CircleAvatar(
                              radius: 400,
                              backgroundColor: Theme.of(context).colorScheme.onSecondary,
                            child: CircleAvatar(
                              radius: 398,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                            ),
                            ),
                        ),
                        Positioned(
                          top: 10,
                          child: Text(
                            '${_userr.name} ${_userr.surname}',
                            style: TextStyle(
                              fontFamily: 'Roboto Condensed',
                              fontSize: 28,
                              color: Theme.of(context).colorScheme.onSecondary
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Theme.of(context).colorScheme.onSecondary,
                                child: CircleAvatar(
                                  radius: 33,
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Theme.of(context).colorScheme.onSecondary,
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
                                        leading: const Icon(Icons.signpost_outlined),
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
                          top: 550,

                            // padding: const EdgeInsets.only(top: 15, right: 20),
                            child: ElevatedButton(
                              child: Text(
                                localizations.editProfile,
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
                        )
                      ],
                    ),
                  ),

        ),
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
    );
  }
}
