import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        title: const Text("Cork Padel"),
      ),
      body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(right: 10),
            height: MediaQuery.of(context).size.height-100,
            width: MediaQuery.of(context).size.width,
            child:
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: -700,
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
                                Icons.contact_mail_outlined,
                                size: 50,
                                color: Theme.of(context).colorScheme.onSecondary,
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
                            style: TextStyle(
                              fontFamily: 'Roboto Condensed',
                              fontSize: 28,
                                color: Theme.of(context).colorScheme.onPrimary
                            ),
                          ),
                        ),
                      ),
                       Positioned(
                        top: 130,
                        child: Card(
                          child: SizedBox(
                            width: 350,
                            child: ListTile(
                              leading: const Icon(Icons.alternate_email),
                              title: const Text('corkpadel@corkpadel.com', style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                              ),
                              onTap: () {
                        launchUrlString(
                            'mailto:corkpadel@corkpadel.com?subject=Cork%20Padel%20Arena', mode: LaunchMode.externalApplication);
                      },
                              trailing: const Icon(Icons.touch_app),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 200,
                        child: Card(
                          child: SizedBox(
                            width: 350,
                            child: ListTile(
                              leading: const Icon(Icons.phone),
                              title: const Text(
                                '91 248 23 38',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              onTap: () async => await launchUrlString('tel://912482338', mode: LaunchMode.externalApplication),
                              trailing: const Icon(Icons.touch_app),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 270,
                        child: Card(
                          child: SizedBox(
                            width: 350,
                            child: ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: const Text("Edifício CORK PADEL,\n"
                                  "Parque desportivo da UDS\n"
                                  "2495-143 Santa Catarina da Serra",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                              onTap: () => launchUrlString("https://goo.gl/maps/jRBM83orrxARDWDA6", mode: LaunchMode.externalApplication),
                              trailing: const Icon(Icons.touch_app),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 400,
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
      floatingActionButton: Badge(
        label: Text(reservationsToCheckOut.length.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
        isLabelVisible: reservationsToCheckOut.isEmpty? false : true,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            showShoppingCart(context).then((value) {
              setState(() {

              });
            });
          },
          child: Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.onSecondary),
        ),
      ),
    );
  }
}
