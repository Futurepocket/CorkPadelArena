import 'package:cork_padel_arena/constants/constants.dart';
import 'package:cork_padel_arena/main.dart';
import 'package:cork_padel_arena/src/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/userr.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserDetails extends StatefulWidget {
  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context)!;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("Cork Padel"),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 80.0,
                  height: 100.0,
                ),
                UserDetailsWidget(),
              ],
            ),
          ),
        ));
  }
}

class UserDetailsWidget extends StatefulWidget {
  @override
  _UserDetailsWidgetState createState() => _UserDetailsWidgetState();
}

class _UserDetailsWidgetState extends State<UserDetailsWidget> {
  void _saveForm() {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    AddUser(Userr().id, Userr().name, Userr().surname, Userr().phoneNbr,
            Userr().address, Userr().city, Userr().postCode, Userr().nif)
        .addUser();

    //await newUser.addUser();
  }

  final nameController = TextEditingController();
  final surnameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = Userr().name;
    surnameController.text = Userr().surname;
  }

  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            AppLocalizations.of(context)!.personalDetails,
            style: TextStyle(
              fontSize: 26,
              color: theme.primaryColor,
            ),
          ),
          Form(
            key: _form,
            child: Column(
              children: [
                Container(
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
//---------------------------------------PRIMEIRO NOME--------------------------------------------------------
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: nameController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.name,
                              autofillHints: [AutofillHints.givenName],
                              decoration: inputDecor(
                                  label: localizations.firstName,
                                  context: context),
                              onSaved: (value) {
                                Userr().name = value.toString();
                              },
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
//---------------------------------------//ULTIMO NOME-------------------------------------------------------------
                          //padding: EdgeInsets.all(10.0),

                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: surnameController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.name,
                              autofillHints: [AutofillHints.familyName],
                              decoration: inputDecor(
                                  label: localizations.familyName,
                                  context: context),
                              onSaved: (value) {
                                Userr().surname = value.toString();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!.required;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ]),
                ),
//---------------------------------------//MORADA-------------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.streetAddress,
                    autofillHints: [AutofillHints.fullStreetAddress],
                    decoration: inputDecor(
                        label: localizations.address,
                        context: context,
                        prefixIcon: Icons.home_work_outlined),
                    onSaved: (value) {
                      Userr().address = value.toString();
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.required;
                      }
                      return null;
                    },
                  ),
                ),
//---------------------------------------//TLM-------------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    autofillHints: [AutofillHints.telephoneNumber],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    decoration: inputDecor(
                        label: localizations.familyName,
                        context: context,
                        prefixIcon: Icons.phone),
                    onSaved: (value) {
                      Userr().phoneNbr = value.toString();
                    },
                    //TODO DIFFERENT COUNTRIES HAVE DIFFERENT VALIDATIONS FOR THIS NUMBER
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.required;
                      }
                      if (value.length > 9) {
                        return AppLocalizations.of(context)!.invalidPhone;
                      }
                      return null;
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
//---------------------------------------//LOCALIDADE-------------------------------------------------------------
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.streetAddress,
                          autofillHints: [AutofillHints.addressCity],
                          decoration: inputDecor(
                              label: localizations.city,
                              context: context,
                              prefixIcon: Icons.location_city),
                          onSaved: (value) {
                            Userr().city = value.toString();
                          },
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
//---------------------------------------//CODIGO POSTAL-------------------------------------------------------------

                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          autofillHints: [AutofillHints.postalCode],
                          decoration: inputDecor(label: localizations.postCode, context: context, prefixIcon: Icons.signpost_outlined),
                          onSaved: (value) {
                            Userr().postCode = value.toString();
                          },
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
//---------------------------------------//NIF-------------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: inputDecor(label: localizations.nif, context: context, prefixIcon: Icons.currency_exchange),
                    onSaved: (value) {
                      Userr().nif = value.toString();
                    },
                    //TODO DIFFERENT COUNTRIES HAVE DIFFERENT VALIDATIONS FOR THIS NUMBER
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.required;
                      }
                      if (double.tryParse(value) == null || value.length < 9) {
                        return AppLocalizations.of(context)!.invalidNif;
                      }

                      return null;
                    },
                  ),
                ),
//---------------------------------------//BOTAO-------------------------------------------------------------

              ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.submit,
                    ),
                    onPressed: () {
                      _saveForm();
                      final isValid = _form.currentState!.validate();
                      if (isValid) {
                        Navigator.pushReplacementNamed(context, '/dash');
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddUser {
  final String _id;
  final String _name;
  final String _surname;
  final String _address;
  final String _city;
  final String _phoneNbr;
  final String _postCode;
  final String _nif;

  User? _user;

  AddUser(this._id, this._name, this._surname, this._phoneNbr, this._address,
      this._city, this._postCode, this._nif);

  CollectionReference users = FirebaseFirestore.instance.collection(userCollection);

  Future<void> addUser() {
    _user = FirebaseAuth.instance.currentUser;
    //Call the user's CollectionReference to add a new user
    return users.doc(_user!.email.toString()).set({
      'id': _id,
      'role': 'utilizador',
      'address': _address,
      'city': _city,
      'email': _user!.email.toString(),
      'first_name': _name,
      'phoneNbr': _phoneNbr,
      'last_name': _surname,
      'nif': _nif,
      'postal_code': _postCode,
    }).then((value) {
      print("User Added");
    }).catchError((error) => print("Failed to add user: $error"));
  }
}
