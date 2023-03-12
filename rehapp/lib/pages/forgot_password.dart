import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/main.dart';
import 'package:rehapp/model/login_model.dart';
import 'package:rehapp/pages/exercise.dart';
import 'package:rehapp/pages/home.dart';
import 'package:rehapp/pages/signup.dart';
import 'package:rehapp/pages/therapist_home.dart';
import 'package:rehapp/pages/assign_exercise.dart';
import 'package:rehapp/pages/exercise_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ProgressHUD.dart';
import '../api/token.dart' as token;
import '../api/user.dart' as user;

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

bool checked = false;

class _ForgotPasswordState extends State<ForgotPassword> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  late LoginRequestModel requestModel;
  bool isApiCallProcess = false;
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
            margin: const EdgeInsets.symmetric(vertical: 85, horizontal: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).hintColor.withOpacity(0.2),
                      offset: Offset(0, 10),
                      blurRadius: 20)
                ]),
            child: Form(
              key: globalFormKey,
              child: Column(children: <Widget>[
                //---------TITLE - RESET PASSWORD--------
                const SizedBox(
                  height: 25,
                ),
                RichText(
                  text: TextSpan(
                    text: RESET_PASSWORD,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
                //-------USER ENTERS EMAIL-------------
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: emailController,
                  validator: (input) =>
                      input!.contains("@") ? null : INVALID_EMAIL_MESSAGE,
                  onSaved: (input) => requestModel.email = input!,
                  decoration: InputDecoration(
                    hintText: "Email",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2)),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 80),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: const StadiumBorder(),
                    primary: Colors.white,
                  ),
                  onPressed: resetPassword,
                  child: const Text(
                    RESET_BUTTON_TEXT,
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
  Future resetPassword() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()));
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      const snackBar = SnackBar(
        content: Text(RESET_SUCCESS_SNACKBAR),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      print(e);
      const snackBar = SnackBar(
        content: Text(RESET_ERROR_SNACKBAR),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.of(context).pop();
    }
  }
}
