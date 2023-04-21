import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/assets/constants.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);
  @override State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  bool isApiCallProcess = false;
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 48),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: const BackButton()
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                //---------TITLE - RESET PASSWORD--------
                RichText(
                  text: TextSpan(
                    text: "Reset Password",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                //-------USER ENTERS EMAIL-------------
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: emailController,
                  validator: (input) => input!.contains("@") ? null : INVALID_EMAIL_MESSAGE,
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
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    prefixIcon: Icon(Icons.email_outlined,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),

                //------RESET BUTTON------------
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: resetPassword,
                  child: const Text(
                    "Reset",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                //---------end reset button-----------
              ]),
            ),
          ),
        ]),
      ),
    );
  }

// ----- Function to Reset Password ------------
  Future<void> resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator())
    );
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      const snackBar = SnackBar(
        content: Text("Link to reset password has been sent"),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      const snackBar = SnackBar(
        content: Text("Password could not be reset"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.of(context).pop();
    }
  }
}