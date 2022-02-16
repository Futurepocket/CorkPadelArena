import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/common_utils.dart';
import 'dash.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {

  @override
  void initState() {
  }
  List<String> playlist= [
    'nlom7a-UiLA',
  ];


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
                  Text(
                    'Cork Padel',
                    style: TextStyle(
                      fontFamily: 'Roboto Condensed',
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Text(
                      AppLocalizations.of(context)!.about,
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
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.moreThanRaquets,
                        style: TextStyle(
                          fontFamily: 'Roboto Condensed',
                          fontSize: 16,
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.only(top:10.0),
                          height: 500,
                          child: const WebView(
                            initialUrl: 'https://www.youtube.com/watch?v=nlom7a-UiLA',
                            javascriptMode: JavascriptMode.unrestricted,
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(AppLocalizations.of(context)!.allAboutUs, style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 16,

                        ),),
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
