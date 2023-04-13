import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  final Widget nextPage;
  const VerifyEmailPage({Key? key, required this.nextPage}) : super(key: key);
  @override State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    //user needs to be created before!
    isEmailVerified = auth.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
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
    await auth.currentUser!.reload();
    setState(() {
      isEmailVerified = auth.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = auth.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      const snackBar = SnackBar(
        content: Text("Email Verification Error"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) => (isEmailVerified) ? (
      widget.nextPage
    ) : Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 23),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              alignment: Alignment.topLeft,
              child: const BackButton()
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              margin: const EdgeInsets.symmetric(vertical: 23, horizontal: 20),
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
              child: Column(
                children: <Widget>[
                  const Text(
                    "Please verify your email through the link sent to your email",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                //------Resend Email BUTTON------------
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
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    child: const Text(
                      "Resend email",
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
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => auth.signOut(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  //---------end cancel button-----------
                ],
              ),
            )
          ]
        )
      ),
    );
}