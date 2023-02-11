import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/user.dart' as user;

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              user.firstname = "";
              user.lastname = "";
              user.role = "";
              user.email = "";
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Phoenix.rebirth(context);
            },
            child: const Text(
              "Logout?",
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.all(15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
