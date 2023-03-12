import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/main.dart';
import 'package:rehapp/model/login_model.dart';
import 'package:rehapp/pages/exercise.dart';
import 'package:rehapp/pages/home.dart';
import 'package:rehapp/pages/login.dart';
import 'package:rehapp/pages/signup.dart';
import 'package:rehapp/pages/therapist_home.dart';
import 'package:rehapp/pages/assign_exercise.dart';
import 'package:rehapp/pages/exercise_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ProgressHUD.dart';
import '../api/token.dart' as token;
import '../api/user.dart' as user;

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    //user needs to be created before!
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    //call after email verification!
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      const snackBar = SnackBar(
        content: Text(VERIFICATION_ERROR_SNACKBAR),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? LoginPage()
      : Scaffold(
          appBar: AppBar(
            title: Text(VERIFY_EMAIL_TITLE),
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  EMAIL_SUCCESS_SNACKBAR,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                //------Resend Email BUTTON------------
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
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  child: const Text(
                    RESENT_EMAIL_BUTTON_TEXT,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                //---------end resend email button-----------
                //------ Cancel BUTTON------------
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
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text(
                    CANCEL_VERIFY_EMAIL_BUTTON_TEXT,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                //---------end cancel button-----------
              ],
            ),
          ),
        );
}
