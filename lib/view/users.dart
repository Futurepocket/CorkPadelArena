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

class _UsersState extends State<Users> {
  List<dynamic> _users = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    FirebaseFirestore.instance.collection('users').orderBy('first_name').get().then((users){
users.docs.forEach((element) {
  setState(() {
    _users.add(element);
  });
});
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ListTile _buildUsersRow(BuildContext context, int index){
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(_users[index]['first_name'] + ' ' + _users[index]['last_name']),
      subtitle: Text(_users[index]['email']),
      onTap: (){
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) {
          return AdminUser(_users[index]);
        }));
      },
    );
  }

  Widget _buildUsersList() {
    return Scrollbar(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _users.length,
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
      body: SingleChildScrollView(
              child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width *0.9,
                      height: MediaQuery.of(context).size.height*0.9,
                      child:
                      Scrollbar(
                        child: _buildUsersList()

                      ),)
                  ]
              ),
            ),
          
    );
  }
}
