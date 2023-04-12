import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/users/user.dart';

class ProfilePage extends StatefulWidget {
  final RehappUser user;
  const ProfilePage({Key? key, required this.user}) : super(key: key);
  @override State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  bool isApiCallProcess = true;
  APIService apiService = APIService();
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Column(
              children: <Widget>[
                const CircleAvatar(
                  backgroundColor: Color(0xffE6E6E6),
                  radius: 30,
                  child: Icon(
                    Icons.person,
                    color: Color(0xffCCCCCC),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Name: ${widget.user.firstName} ${widget.user.lastName}\n"
                  "Email: ${widget.user.email}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                )
              ]
            ),
            const SizedBox(height: 20),
            Column(
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Phoenix.rebirth(context);
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                      ),
                    ),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.all(15),
                      ),
                    ),
                  ),
                )
              ]
            )
          ]
        )
      )
    );
  }
}
