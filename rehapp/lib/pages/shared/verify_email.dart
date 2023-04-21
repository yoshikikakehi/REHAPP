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
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    //user needs to be created before!
    if (!auth.currentUser!.emailVerified) {
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

    if (auth.currentUser!.emailVerified) {
      timer?.cancel();
      if (mounted) {
        const snackBar = SnackBar(content: Text("Login Successful"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => widget.nextPage),
          (route) => false
        );
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = auth.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 48),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: BackButton(
                onPressed: () async {
                  timer?.cancel();
                  await FirebaseAuth.instance.signOut()
                    .then((_) {
                      Navigator.pop(context);
                    });
                },
              )
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
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
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: const Text(
                      "Please verify your email through the link sent to your email",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                //------Resend Email BUTTON------------
                  const SizedBox(
                    height: 30,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
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
                ],
              ),
            )
          ]
        )
      ),
    );
}