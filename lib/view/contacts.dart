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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Cork Padel Arena',
                    style: TextStyle(
                      fontFamily: 'Roboto Condensed',
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Text(
                      AppLocalizations.of(context)!.contacts,
                      style: const TextStyle(
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
                        padding: const EdgeInsets.only(top:15.0, right: 5),
                        child: Text("Email:", style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextButton(
                          onPressed: (){
                          launchUrlString('corkpadel@corkpadel.com');
                        }, child: const Text('corkpadel@corkpadel.com', style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:5.0, top:5),
                        child: Text("Telemóvel:", style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold
                        ),),
                      ),

                      TextButton(
                        child: const Text(
                          '91 248 23 38',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        onPressed: () async{
                          await launchUrlString('tel://912482338');
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:5.0, top:5),
                        child: Text("Morada:", style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold
                        ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left:5.0, top:5),
                        child: Text("Edifício CORK PADEL,\n"
                            "Parque desportivo da UDS\n"
                            "2495-143 Santa Catarina da Serra",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                        ),),
                      ),
                        TextButton(onPressed: (){
                          launchUrlString("https://goo.gl/maps/jRBM83orrxARDWDA6");
                        }, child: const Text("Ver no Mapa"),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10.0),
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
