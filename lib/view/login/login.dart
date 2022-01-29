import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/utils/firebase_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../models/userr.dart';

class Login extends StatefulWidget {

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_LoginFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  var _isObscure = true;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
        title: Text("Cork Padel", style: TextStyle(color: Colors.white),),
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
                    children: [
                      Text(
                        AppLocalizations.of(context)!.signIn,
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.lime,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _emailController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.lime, width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.lime, width: 1.5),
                                    ),
                                    labelText: 'Email',
                                  ),
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
                                  obscureText: _isObscure,
                                  decoration: InputDecoration(
                                    suffixIcon:
                                    GestureDetector(
                                        onTap: () => setState(() {
                                          print('tapping');
                                          _isObscure = !_isObscure;
                                        }),
                                        child: Icon(_isObscure? Icons.visibility : Icons.visibility_off)),
                                    contentPadding: EdgeInsets.all(10),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.lime, width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.lime, width: 1.5),
                                    ),
                                    labelText: AppLocalizations.of(context)!.password,
                                    // errorText: 'Error Text',
                  ),
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.required;
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.login,
                      style: TextStyle(fontSize: 15),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                       signInWithEmailAndPassword(
                            _emailController.text,
                            _passwordController.text,
                                (e) => showErrorDialog(context, AppLocalizations.of(context)!.loginError, e))
                           .then((thisFbUser) {
                         if(thisFbUser != null){
                           print(thisFbUser);
                           if(emailVerified){
                             final String _email = thisFbUser.email.toString();
                             FirebaseFirestore.instance
                                 .collection('users')
                                 .doc(_email).get().then((value) {
                                   if(value.exists){
                                     Navigator.of(context).pushReplacementNamed('/dash');
                                   }
                                   else {
                                     Navigator.of(context).pushReplacementNamed(
                                         '/userDetails');
                                   }
                             });

                           }else{
                             Navigator.of(context).pushReplacementNamed('/emailVerify');
                           }
                         }
                       });
                      }

                    },
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.lime,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: AppLocalizations.of(context)!.forgotPassword),
                      TextSpan(
                          text: AppLocalizations.of(context)!.tapHere,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.lime,
                              fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                    email: _emailController.text);
                                showToast(context: context);
                              } on FirebaseAuthException catch (er) {
                                showErrorDialog(
                                    context, AppLocalizations.of(context)!.enterYourEmail, er);
                              }
                            })
                    ]),
              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(AppLocalizations.of(context)!.or, style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.lime,
                                )),
                              ),

                              Container(
                                  width: 150,
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context).primaryColor,
                                      onPrimary: Colors.white,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.register,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    onPressed: () {
                                          Navigator.of(context).pushNamed('/register')
                                              .then((value) {
                                                if(Userr().email != ''){
                                                  setState(() {
                                                    _emailController.text = Userr().email;
                                                  });
                                                }
                                          }
                                          );

                                    },
                                  ),
                                ),

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