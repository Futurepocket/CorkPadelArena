import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/common_utils.dart';
import 'dash.dart';

class Contacts extends StatefulWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Cork Padel", style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(right: 10),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child:
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        bottom: 850,
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
                                Icons.contact_mail_outlined,
                                size: 50,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text(
                            AppLocalizations.of(context)!.contacts,
                            style: const TextStyle(
                              fontFamily: 'Roboto Condensed',
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                       Positioned(
                        top: 130,
                        child: Card(
                          child: Container(
                            width: 350,
                            child: ListTile(
                              leading: const Icon(Icons.alternate_email),
                              title: const Text('corkpadel@corkpadel.com', style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                              ),
                              ),
                              onTap: () => launchUrlString('corkpadel@corkpadel.com'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 200,
                        child: Card(
                          child: Container(
                            width: 350,
                            child: ListTile(
                              leading: const Icon(Icons.phone),
                              title: const Text(
                                '91 248 23 38',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              onTap: () async => await launchUrlString('tel://912482338'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 270,
                        child: Card(
                          child: Container(
                            width: 350,
                            child: ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: const Text("Edifício CORK PADEL,\n"
                                  "Parque desportivo da UDS\n"
                                  "2495-143 Santa Catarina da Serra",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold
                                ),),
                              onTap: () => launchUrlString("https://goo.gl/maps/jRBM83orrxARDWDA6"),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 370,
                        child: Image.asset(
                            'assets/images/arena.jpeg',
                            width: 432.0,
                            height: 243.0,
                          ),
                      ),
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
                  setState(() {

                  });
                });
              },
              child: const Icon(Icons.shopping_cart, color: Colors.white,),
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
