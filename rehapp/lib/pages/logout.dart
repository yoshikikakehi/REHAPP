import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/user.dart' as user;


class LogoutPage extends StatefulWidget {
  @override
  Logout createState() => Logout();
}

class Logout extends State<LogoutPage> {
  String userInfo = "";

  @override
  void initState() {
    super.initState();
    updateInfo();
    print(userInfo);
  }

  Future<String> updateInfo() async {
    APIService apiService = APIService();
    String info = "";
    apiService.getCurrentUserData().then((userValue) {
      setState(() {
        info = userValue.toString();
        info = "Name: " + userValue['firstname'] + " " + userValue['lastname'];
        info = info + "\nRole: " + userValue['role'] + "\nEmail: " + userValue['email'];
        info = info + "\nTherapist Contact Number (8am -8pm): " + "(800)-111-111";

        //print(info);
        userInfo = info;
    });
    });
    print(userInfo);
    return info;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: ListView(
        shrinkWrap: true,
          //mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
        children: [SizedBox(
        width: 200,
        height: 200,
        child: Align(
          alignment: Alignment.center,

          child: Column( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              user.firstname = "";
              user.lastname = "";
              user.role = "";
              user.email = "";
              SharedPreferences prefs = await SharedPreferences.getInstance();
              print(prefs);
              await prefs.clear();
              Phoenix.rebirth(context);
            },
            child: const Text(
              "Logout",
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.all(15),
              ),
            ),
          ),
            MaterialButton(
                color: Colors.blue,
                child: const Text(
                    "Pick Image from Gallery",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold
                    )
                ),
                onPressed: () {
                  File? image;
                  Future pickImage() async {
                    try {
                      //final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if(image == null) return;
                      //final imageTemp = File(image.path);
                      //setState(() => this.image = imageTemp);
                    } on PlatformException catch(e) {
                      print('Failed to pick image: $e');
                    }
                  }
                }
            ),
            MaterialButton(
                color: Colors.blue,
                child: const Text(
                    "Pick Image from Camera",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold

                    )
                ),
                onPressed: () {
                  File? image;
                  Future pickImage() async {
                    try {
                      //final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if(image == null) return;
                      //final imageTemp = File(image.path);
                      //setState(() => this.image = imageTemp);
                    } on PlatformException catch(e) {
                      print('Failed to pick image: $e');
                    }
                  }
                }

            ),


          ]
          )
        )
      ),
          Container(
            margin: const EdgeInsets.all(10.0),
          color: Colors.white,
          width: 100,
          height: 300,
          child: Center(
            child: Text(
              userInfo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 40,
              ),
            ),
          ),
        )
      ] //children
    )
    );
  }



}

