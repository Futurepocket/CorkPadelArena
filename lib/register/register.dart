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
        title: const Text("Cork Padel")
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 80),
        child: Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                          color: Theme.of(context).colorScheme.secondary,
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
                                        keyboardType: TextInputType.name,
                                        autofillHints: [AutofillHints.givenName],
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.secondary,
                                                width: 1.5),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.secondary,
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
                                        keyboardType: TextInputType.name,
                                        autofillHints: [AutofillHints.familyName],
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.secondary,
                                                width: 1.5),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.secondary,
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
                                autofillHints: [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.secondary, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.secondary, width: 1.5),
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
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                enableSuggestions: false,
                                autocorrect: false,
                                obscureText: true,
                                autofillHints: [AutofillHints.password],
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
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
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                enableSuggestions: false,
                                autocorrect: false,
                                obscureText: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  focusedBorder:  OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
                                  ),
                                  enabledBorder:  OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
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
                                        foregroundColor: Theme.of(context).colorScheme.onSecondary, backgroundColor: Theme.of(context).colorScheme.secondary,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.submit,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          registerAccount(
                                            _emailController.text,
                                            _displayNameController.text,
                                            _passwordController.text,
                                                  (e) => showErrorDialog(context, AppLocalizations.of(context)!.registerError, e)
                                          ).then((value) {
                                            if(value == true){
                                              getUserDetails().then((user){
                                                Userr().id = user!.uid.toString();
                                                Userr().email = user.email.toString();
                                                Userr().name = _displayNameController.text;
                                                Userr().surname = _displaySurnameController.text;
                                                Userr().email = _emailController.text;
                                                user.sendEmailVerification();
                                              });
                                              Navigator.pushReplacementNamed(context, '/splash');
                                            }
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
