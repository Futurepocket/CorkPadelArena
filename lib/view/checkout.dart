import 'dart:convert';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/view/mbway_payment.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';

class Checkout extends StatefulWidget {
  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  Future<void>? _launched;
  checkoutValue _check = checkoutValue();

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }
  DatabaseReference database = FirebaseDatabase.instance.ref();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text("Pagamento"),
          backgroundColor: Theme.of(context).primaryColor),
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                'assets/images/logo.png',
                width: 80.0,
                height: 100.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Pagamento',
                style: TextStyle(
                  fontFamily: 'Roboto Condensed',
                  fontSize: 26,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Valor total: €' + _check.price.toString(),
                style: TextStyle(
                  fontFamily: 'Roboto Condensed',
                  fontSize: 24,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                    icon: Image.asset('assets/images/mb.png'),
                    iconSize: 75,
                    onPressed: () async {

                      if (await canLaunch(
                          'http:/corkpadel-arena-eb47b.web.app/ifmb.html?ENTIDADE=12375&SUBENTIDADE=610&ID=0000&VALOR=10.00')) {
                        await launch(
                          'http:/corkpadel-arena-eb47b.web.app/ifmb.html?ENTIDADE=12375&SUBENTIDADE=610&ID=0000&VALOR=10.00',
                          forceWebView: false,
                          //headers: <String, String>{'my_header_key': 'my_header_value'},
                        );
                      } else {
                        throw 'Could not launch the store';
                      }
                    },
                  ),
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                    icon: Image.asset('assets/images/Logo_MBWay.png'),
                    iconSize: 75,
                    onPressed: () {
                        Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) {
                        return MbWayPayment();
                      }));
                    },
                  ),
                ),
              ],
            ),
            FutureBuilder<void>(future: _launched, builder: _launchStatus),
          ],
        )),
      ),
    );
  }

  Future<http.Response> fetchAlbum() {
    return http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));
  }

  void payWithMBWay() {
    Uri uri = Uri.parse('/ifthenpaymbw.asmx/SetPedidoJSON HTTP/1.1');
    //'https://us-central1-corkpadel-arena-eb47b.cloudfunctions.net/corkArenas?chave=[CHAVE_ANTI_PHISHING]&referencia=[REFERENCIA]&idpedido=[ID_TRANSACAO]&valor=[VALOR]&datahorapag=[DATA_HORA_PAGAMENTO]&estado=[ESTADO]';
    http.post(uri, body: json.encode({}));
  }
}
