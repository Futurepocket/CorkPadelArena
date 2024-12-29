import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/apis/local_auth_api.dart';
import 'package:cork_padel_arena/constants/constants.dart';
import 'package:cork_padel_arena/main.dart';
import 'package:cork_padel_arena/src/constants.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/utils/firebase_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../models/userr.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

String appVersion = "";

class _LoginState extends State<Login> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>(debugLabel: '_LoginFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _accountNameController =
      TextEditingController(text: 'flutter_secure_storage_service');
  String? _email;
  String? _password;
  List<_SecItem> _items = [];
  bool _alreadyLoggedIn = false;

  String? _getAccountName() =>
      _accountNameController.text.isEmpty ? null : _accountNameController.text;

  IOSOptions _getIOSOptions() => IOSOptions(
        accountName: _getAccountName(),
      );

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<void> _readAll() async {
    final all = await _storage.readAll(
        iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
    _email = await _storage.read(
      key: 'email',
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
    _password = await _storage.read(
      key: 'password',
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );

    setState(() {
      _items = all.entries
          .map((entry) => _SecItem(entry.key, entry.value))
          .toList(growable: false);
    });
  }

  Future<void> _deleteAll() async {
    await _storage.deleteAll(
        iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
    _readAll();
  }

  void _addEmail() async {
    const String key = 'email';
    final String value = _emailController.text;

    await _storage.write(
        key: key,
        value: value,
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions());
    _readAll();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void _addPassword() async {
    const String key = 'password';
    final String value = _passwordController.text;

    await _storage.write(
        key: key,
        value: value,
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions());
    _readAll();
  }

  void _signInBio() async {
    bool success = await LocalAuthApi.authenticate();
    if (success == true) {
      setState(() {
        _emailController.text = _email!;
        _passwordController.text = _password!;
      });
      signInWithEmailAndPassword(
              _email!,
              _password!,
              (e) => showErrorDialog(
                  context, AppLocalizations.of(context)!.loginError, e))
          .then((thisFbUser) {
        loggedInBefore = true;
        getUserDetails().then((value) {
          checkEmailVerified(fbUser!).then((value) {
            if (value == true) {
              final String email = fbUser!.email.toString();
              FirebaseFirestore.instance
                  .collection(userCollection)
                  .doc(email)
                  .get()
                  .then((value) {
                if (value.exists) {
                  Navigator.of(context).pushReplacementNamed('/dash');
                } else {
                  Navigator.of(context).pushReplacementNamed('/userDetails');
                }
              });
            } else {
              Navigator.of(context).pushReplacementNamed('/emailVerify');
            }
          });
        });
      });
    }
  }

  void _signIn() {
    signInWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
            (e) => showErrorDialog(
                context, AppLocalizations.of(context)!.loginError, e))
        .then((thisFbUser) {
      loggedInBefore = true;
      _deleteAll().then((v) {
        _addEmail();
        _addPassword();
        if (thisFbUser != null) {
          getUserDetails().then((value) {
            checkEmailVerified(fbUser!).then((value) {
              if (value == true) {
                final String email = fbUser!.email.toString();
                print(fbUser?.displayName);
                print(fbUser?.email);
                FirebaseFirestore.instance
                    .collection(userCollection)
                    .doc(email)
                    .get()
                    .then((value) async {
                  print(value.data());
                  if (!kIsWeb) {
                    // final String? fcmToken = await messaging.getToken(vapidKey: "kPjxDW4z1Klemmfwcw7CJNqA8IFloeTNFoD6lgOc8n0");
                    // print("fcmToken: $fcmToken");

                    // final String? fcmToken = await messaging
                    //     .getToken();
                  }

                  if (value.exists) {
                    Navigator.of(context).pushReplacementNamed('/dash');
                  } else {
                    Navigator.of(context).pushReplacementNamed('/userDetails');
                  }
                });
              } else {
                Navigator.of(context).pushReplacementNamed('/emailVerify');
              }
            });
          });
        }
      });
    });
  }

  bool checked = false;

  @override
  void initState() {
    _accountNameController.addListener(() => _readAll());
    _readAll().then((v) {
      if (_items.isNotEmpty && _items[0].key.isNotEmpty) {
        setState(() {
          _alreadyLoggedIn = true;
        });
        if (loggedInBefore == false) {
          _signInBio();
        }
        if (kIsWeb) {
          _emailController.text = _email!;
        }
      }
    });
    super.initState();
  }

  var _isObscure = true;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    localizations = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Cork Padel"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 12,
            child: Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: 450,
              padding: EdgeInsets.all(20),
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
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _emailController,
                                    autofillHints: const [AutofillHints.email],
                                    enableSuggestions: true,
                                    enableInteractiveSelection: true,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: inputDecor(
                                        prefixIcon: Icons.alternate_email,
                                        label: 'Email',
                                        context: context),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .required;
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
                                    autofillHints: [AutofillHints.password],
                                    textInputAction: TextInputAction.go,
                                    decoration: inputDecor(
                                        prefixIcon: Icons.password,
                                        context: context,
                                        label: localizations.password,
                                        sufixIcon: IconButton(
                                            onPressed: () => setState(() {
                                                  _isObscure = !_isObscure;
                                                }),
                                            icon: Icon(_isObscure
                                                ? Icons.visibility
                                                : Icons.visibility_off))),
                                    controller: _passwordController,
                                    onFieldSubmitted: (value) {
                                      if (_formKey.currentState!.validate()) {
                                        _signIn();
                                      }
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .required;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: FittedBox(
                                    fit: BoxFit.none,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.login),
                                      label: Text(
                                        AppLocalizations.of(context)!
                                            .login.toUpperCase(),
                                      ),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          _signIn();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                if (kIsWeb == false && _alreadyLoggedIn == true)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: FittedBox(
                                      fit: BoxFit.none,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.fingerprint),
                                          label: const Text('LOGIN Biométrico'),
                                          onPressed: () {
                                            _signInBio();
                                          }),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .forgotPassword),
                                          TextSpan(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .tapHere,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  fontWeight: FontWeight.bold),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  try {
                                                    await FirebaseAuth.instance
                                                        .sendPasswordResetEmail(
                                                            email:
                                                                _emailController
                                                                    .text);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            newSnackBar(
                                                      context,
                                                      Text(AppLocalizations.of(
                                                              context)!
                                                          .recoveryEmailSent),
                                                    ));
                                                  } on FirebaseAuthException catch (er) {
                                                    showErrorDialog(
                                                        context,
                                                        AppLocalizations.of(
                                                                context)!
                                                            .enterYourEmail,
                                                        er);
                                                  }
                                                })
                                        ]),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(AppLocalizations.of(context)!.or,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: theme.colorScheme.secondary,
                                      )),
                                ),
                                FittedBox(
                                  fit: BoxFit.none,
                                  // padding: const EdgeInsets.only(
                                  //     left: 10, right: 10),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.app_registration),
                                    label: Text(
                                      AppLocalizations.of(context)!
                                          .register.toUpperCase(),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed('/register')
                                          .then((value) {
                                        if (Userr().email != '') {
                                          setState(() {
                                            _emailController.text =
                                                Userr().email;
                                          });
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text("Versão ${packageInfo.version}"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecItem {
  _SecItem(this.key, this.value);

  final String key;
  final String value;
}
