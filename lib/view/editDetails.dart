import '../src/profileUpdatedSplash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/userr.dart';

class EditDetails extends StatefulWidget {
  final Function settingState;

  const EditDetails({Key? key, required this.settingState}) : super(key: key);
  @override
  _EditDetailsState createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("Cork Padel Arena"),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 80.0,
                    height: 100.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: EditDetailsWidget(settingState: widget.settingState,),
                  ),
                ],
              ),
          ),
        ));
  }
}

class EditDetailsWidget extends StatefulWidget {
  final Function settingState;

  const EditDetailsWidget({Key? key, required this.settingState}) : super(key: key);
  @override
  State<EditDetailsWidget> createState() => _EditDetailsWidgetState();
}

class _EditDetailsWidgetState extends State<EditDetailsWidget> {
  Userr _userr = Userr();

  void _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    AddUser(_userr.id, _userr.name, _userr.surname, _userr.phoneNbr, _userr.address, _userr.city,
            _userr.postCode, _userr.nif, _userr.email)
        .addUser();

    //await newUser.addUser();
  }

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final addressController = TextEditingController();
  final postCodeController = TextEditingController();
  final cityController = TextEditingController();
  final nifController = TextEditingController();
  final phoneNbrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = _userr.name;
    phoneNbrController.text = _userr.phoneNbr;
    surnameController.text = _userr.surname;
    addressController.text = _userr.address;
    postCodeController.text = _userr.postCode;
    cityController.text = _userr.city;
    nifController.text = _userr.nif;
  }

  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            'EDITAR DADOS',
            style: TextStyle(
              fontFamily: 'Roboto Condensed',
              fontSize: 26,
              color: Theme.of(context).primaryColor,
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
                              onSaved: (value) {
                                _userr.name = value.toString();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Obrigatorio';
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
                              onSaved: (value) {
                                _userr.surname = value.toString();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Obrigatorio';
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
                    controller: addressController,
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
                      labelText: 'Morada',
                      // errorText: 'Error Text',
                    ),
                    onSaved: (value) {
                      _userr.address = value.toString();
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Obrigatorio';
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
                          controller: cityController,
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
                            labelText: 'Localidade',
                            // errorText: 'Error Text',
                          ),
                          onSaved: (value) {
                            _userr.city = value.toString();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Obrigatorio';
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
                          controller: postCodeController,
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
                            labelText: 'Codigo Postal',
                            // errorText: 'Error Text',
                          ),
                          onSaved: (value) {
                            _userr.postCode = value.toString();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Obrigatorio';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
//---------------------------------------//TLM-------------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: phoneNbrController,
                    textInputAction: TextInputAction.next,
                    autofillHints: [AutofillHints.telephoneNumber],
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: false),
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
                      labelText: 'Numero de Telemovel',
                      // errorText: 'Error Text',
                    ),
                    onSaved: (value) {
                      _userr.phoneNbr = value.toString();
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Obrigatorio';
                      }
                      if (double.tryParse(value) == null || value.length < 9) {
                        return 'NIF invalido';
                      }

                      return null;
                    },
                  ),
                ),
//---------------------------------------//NIF-------------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: nifController,
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                      labelText: 'NIF',
                      // errorText: 'Error Text',
                    ),
                    onSaved: (value) {
                      _userr.nif = value.toString();
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Obrigatorio';
                      }
                      if (double.tryParse(value) == null || value.length < 9) {
                        return 'NIF invalido';
                      }

                      return null;
                    },
                  ),
                ),
//---------------------------------------//BOTAO-------------------------------------------------------------
                Container(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, primary: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      "Submeter",
                      style: TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      _saveForm();
                      final isValid = _form.currentState!.validate();
                      if (isValid) {
                        widget.settingState();
                        Navigator.of(
                          context,
                        ).pop();
                      }
                    },
                  ),
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
  final String _phoneNbr;
  final String _city;
  final String _postCode;
  final String _nif;
  final String _email;

  User? _user = FirebaseAuth.instance.currentUser;

  AddUser(this._id, this._name, this._surname, this._phoneNbr, this._address, this._city,
      this._postCode, this._nif, this._email);

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser() {
    //Call the user's CollectionReference to add a new user
    return users.doc(_email).set({
      'id': _id,
      'role': Userr().role,
      'address': _address,
      'city': _city,
      'email': _email,
      'phoneNbr': _phoneNbr,
      'first_name': _name,
      'last_name': _surname,
      'nif': _nif,
      'postal_code': _postCode
    }).then((value) {
      print("User Added");
    }).catchError((error) => print("Failed to add user: $error"));
  }
}
