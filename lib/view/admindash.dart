import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/src/constants.dart';
import 'package:cork_padel_arena/models/checkoutValue.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/view/widgets/shopping_cart_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cork_padel_arena/models/menuItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AdminDash extends StatefulWidget {
  @override
  _AdminDashState createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  DatabaseReference database = FirebaseDatabase.instance.ref();
  final checkoutValue _check = checkoutValue();
  var myName;

  getUser() async {
    await currentUser().then((value) {
      setState(() {
        myName = Userr().name;
      });
    });
  }

  settingState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Align(
            child: Text("Cork Padel Arena")),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          AppLocalizations.of(context)!.admin,
                          style: TextStyle(
                            fontSize: 26,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          child: GridView(
                            padding: const EdgeInsets.all(5),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 150,
                                  childAspectRatio: 0.5,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 0,
                                  mainAxisExtent: 150,
                            ),
                            children: getAdminDashButtons(context)
                                .map((menus) => Menu_Item(ikon: menus.ikon,
                                    title: menus.title, fun: menus.fun, color: menus.color,))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const ShoppingCartButton(),
    );
  }
}
