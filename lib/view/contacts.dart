import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: Text("Cork Padel", style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 20),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 80.0,
                        height: 100.0,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context)!.contacts,
                          style: TextStyle(
                            fontSize: 26,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:10.0),
                        child: Text(
                          "Email",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text("Encomendas:", style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: LinkWell(
                              'encomendas@corkpadel.com',
                              linkStyle: TextStyle(
                                  fontStyle: FontStyle.italic,
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text("Comercial:", style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: LinkWell(
                          'pedroplantier@corkpadel.com',
                          linkStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text("Geral:", style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: LinkWell(
                          'corkpadel@corkpadel.com',
                          linkStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:10.0),
                        child: Text(
                          "FÁBRICA CORK PADEL",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text("Email:", style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: LinkWell(
                          'corkpadel@corkpadel.com',
                          linkStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
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
                          child: Text(
                          '91 248 23 38',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                          onPressed: () async{
                            await launch('tel://912482338');
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left:5.0, top:5),
                        child: Text("Telefone:", style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      TextButton(
                        child: Text(
                          '249 09 60 29',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        onPressed: () async{
                          await launch('tel://249096029');
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
                      Padding(
                        padding: const EdgeInsets.only(left:5.0, top:5),
                        child: const Text("Travessa da Charneca do Algar de Água,\n nº111 => "
                            "2495-405 Fátima",
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              color: Colors.black,
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:5.0, top:5),
                        child: const Text("(Visitas só autorizadas a Revendedores da CORK!)",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Image.asset(
                            'assets/images/fabrica-cork-iewdv1.jpg',
                            width: 432.0,
                            height: 243.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:10.0),
                        child: Text(
                          "ARENA CORK PADEL",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:10.0),
                        child: Text(
                          "LOJA & INDOOR PADEL",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text("Email:", style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: LinkWell(
                          'corkpadel@corkpadel.com',
                          linkStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
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
                        child: Text(
                          '91 248 23 38',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        onPressed: () async{
                          await launch('tel://912482338');
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
                      Padding(
                        padding: const EdgeInsets.only(left:5.0, top:5),
                        child: const Text("Edifício CORK PADEL,\n"
                            "Parque desportivo da UDS\n"
                            "2495-143 Santa Catarina da Serra",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                        ),),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Image.asset(
                            'assets/images/arena.jpg',
                            width: 432.0,
                            height: 243.0,
                          ),
                        ),
                      ),
                    ],
                  )
                ]
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
