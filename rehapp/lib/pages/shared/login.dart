import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/pages/shared/forgot_password.dart';
import 'package:rehapp/pages/shared/home.dart';
import 'package:rehapp/pages/shared/signup.dart';
import 'package:rehapp/pages/shared/verify_email.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isApiCallProcess = false;

  String email = "";
  String password = "";
  bool hidePassword = true;

  APIService apiService = APIService();

  @override
  void initState() {
    super.initState();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      setState(() => isApiCallProcess = true);
      // if (user.emailVerified) {
        Future(() => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        )).then((value) => setState(() => isApiCallProcess = false));
      // } else {
      //   Future(() => Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const VerifyEmailPage(nextPage: HomePage())),
      //   ));
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            margin: const EdgeInsets.only(top: 120, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).hintColor.withOpacity(0.2),
                  offset: const Offset(0, 10),
                  blurRadius: 20
                )
              ]
            ),
            child: Form(
              key: globalFormKey,
              child: Column(children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: LOGIN_TO,
                    style: Theme.of(context).textTheme.headlineMedium,
                    children: const <TextSpan>[
                      TextSpan(
                        text: APP_NAME,
                        style: TextStyle(fontWeight: FontWeight.w900),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autofocus: true,
                  validator: (input) => input!.contains("@") ? null : INVALID_EMAIL_MESSAGE,
                  onSaved: (input) => setState(() => email = input!),
                  decoration: InputDecoration(
                    hintText: "Email",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2)
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                    ),
                    prefixIcon: Icon(Icons.email_outlined,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  validator: (input) => input!.isEmpty ? "Please enter a password" : null,
                  onSaved: (input) => setState(() => password = input!),
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                    ),
                    prefixIcon: Icon(Icons.lock_outlined,
                        color: Theme.of(context).colorScheme.secondary),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
                      icon: Icon(hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    if (validateAndSave()) {
                      setState(() {
                        isApiCallProcess = true;
                      });
                      apiService
                        .login(email, password)
                        .then((userCredential) async {
                          setState(() {
                            isApiCallProcess = false;
                          });
                          if (userCredential.user != null) {
                            globalFormKey.currentState!.reset();
                            if (userCredential.user!.emailVerified) {
                              const snackBar = SnackBar(content: Text("Login Successful"));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const HomePage())
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const VerifyEmailPage(nextPage: HomePage()))
                              );
                            }
                            
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Failure"))
                            );
                          }
                        }).catchError((onError) {
                          setState(() {
                            isApiCallProcess = false;
                          });
                          const snackBar = SnackBar(
                            content: Text("Login failed"),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                    }
                  },
                  child: const Text(
                    LOGIN_BUTTON_TEXT,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: InkWell(
                    onTap: () {
                      globalFormKey.currentState!.reset();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ForgotPasswordPage())
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Forgot Password? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: const <TextSpan>[
                          TextSpan(
                              text: "Reset password here.",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: InkWell(
                    onTap: () {
                      globalFormKey.currentState!.reset();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupPage())
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: DONT_HAVE_ACCOUNT,
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: const <TextSpan>[
                          TextSpan(
                              text: CREATE_ONE_NOW,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
