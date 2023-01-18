import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/view/admin_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/userr.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> with TickerProviderStateMixin {
  List<Tab> tabs = [];
  late TabController _tabController;
  List<dynamic> activeUsers =[];

  //List<dynamic> _users = [];
  late ScrollController _scrollController;
  Map<String, dynamic> userMap = {};
  String activeLetter = "A";

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(length: 0, vsync: this);
    List<Tab> tempTabs = [];
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('first_name')
        .get()
        .then((users) {
      for (var user in users.docs) {
          String letter = user['first_name'][0];
          if (tempTabs.any((element) => element.text == letter.toUpperCase())) {}
          else{
            tempTabs.add(Tab(
              text: letter.toUpperCase(),
            ));
            _tabController = TabController(length: tempTabs.length, vsync: this);
          }
          if (userMap[letter] == null) {
            userMap.putIfAbsent(letter, () => [user]);
          } else {
            userMap[letter].add(user);
          }
          //_users.add(element);
      }
      setState(() {
        tabs = tempTabs;
        activeUsers = userMap[activeLetter];
        _tabController = TabController(length: tabs.length, vsync: this);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ListTile _buildUsersRow(BuildContext context, int index) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(activeUsers[index]['first_name'] +
          ' ' +
          activeUsers[index]['last_name']),
      subtitle: Text(activeUsers[index]['email']),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) {
          return AdminUser(activeUsers[index]);
        }));
      },
    );
  }

  Widget _buildUsersList() {
    return Scrollbar(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: activeUsers.length,
        itemBuilder: _buildUsersRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.users),
          backgroundColor: Theme.of(context).primaryColor),
      body: Scaffold(
        appBar: AppBar(
          elevation: 8,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                  tabs: tabs,
                  indicatorColor: Colors.white,
                  labelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1),
                  controller: _tabController,
                  isScrollable: true,
                  onTap: (index) {
                    setState(() {
                      activeLetter = tabs[index].text!;
                      activeUsers = userMap[activeLetter];
                    });
                  }),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height-150,
              child: Scrollbar(child: _buildUsersList()),
            )
          ]),
        ),
      ),
    );
  }
}
