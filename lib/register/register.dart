import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/utils/firebase_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../models/userr.dart';


class Register extends StatefulWidget {


  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterFormState');
  final _displayNameController = TextEditingController();
  final _displaySurnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Cork Padel"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 80),
        child: Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 80.0,
                    height: 100.0,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.registration,
                        style: TextStyle(
                          fontSize: 26,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: TextFormField(
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).primaryColor,
                                                width: 1.5),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).primaryColor,
                                                width: 1.5),
                                          ),
                                          labelText: 'Nome',
                                          // errorText: 'Error Text',
                                        ),
                                        controller: _displayNameController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return AppLocalizations.of(context)!.required;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: TextFormField(
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).primaryColor,
                                                width: 1.5),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).primaryColor,
                                                width: 1.5),
                                          ),
                                          labelText: 'Sobrenome',
                                          // errorText: 'Error Text',
                                        ),
                                        controller: _displaySurnameController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return AppLocalizations.of(context)!.required;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor, width: 1.5),
                                  ),
                                  labelText: 'Email',
                                  // errorText: 'Error Text',
                                ),
                                controller: _emailController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
//---------------------------------------//PASSWORD-------------------------------------------------------------
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                enableSuggestions: false,
                                autocorrect: false,
                                obscureText: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.lime, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.lime, width: 1.5),
                                  ),
                                  labelText: 'Password',
                                  // errorText: 'Error Text',
                                ),
                                controller: _passController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                enableSuggestions: false,
                                autocorrect: false,
                                obscureText: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.lime, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.lime, width: 1.5),
                                  ),
                                  labelText: AppLocalizations.of(context)!.confirmPassword,
                                  // errorText: 'Error Text',
                                ),
                                controller: _passwordController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!.required;
                                  }
                                  if (value != _passController.text) {
                                    return AppLocalizations.of(context)!.passwordsNotMatch;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Container(
                              width: 150,
                              child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Theme.of(context).primaryColor,
                                        onPrimary: Colors.white,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.submit,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          registerAccount(
                                            _emailController.text,
                                            _displayNameController.text,
                                            _passwordController.text,
                                                  (e) => showErrorDialog(context, AppLocalizations.of(context)!.registerError, e)
                                          ).then((value) {
                                            getUserDetails();
                                            Userr().name = _displayNameController.text;
                                            Userr().surname = _displaySurnameController.text;
                                            Userr().email = _emailController.text;
                                            fbUser!.sendEmailVerification();
                                            Navigator.pushReplacementNamed(context, '/splash');
                                          });
                                        }
                                      },
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ]
          ),
        ),
      ),

    );
  }
  }





class ToastWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.0,
      width: MediaQuery.of(context).size.width - 20,
      left: 10,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Material(
          color: Colors.lime,
          elevation: 10.0,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              'Email de Recuperacao de Password Enviado',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
