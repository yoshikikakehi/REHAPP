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
  bool showingTherapists = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(30, 136, 229, 1),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: Text(
                          '${widget.user.firstName} ${widget.user.lastName}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis,
                          )
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 30),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundColor: Color.fromARGB(188, 185, 185, 185),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 57.5,
                            child: Icon(
                              Icons.person,
                              color: Color.fromRGBO(100, 181, 246, 1),
                              size: 85,
                            ),
                          ),
                        ),
                      ),
                    ]
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.person_outlined,
                      color: Color.fromRGBO(100, 181, 246, 1),
                      size: 30,
                    ),
                    const SizedBox(width: 30),
                    SizedBox(
                      width: 250,
                      child: Text(
                        '${widget.user.firstName} ${widget.user.lastName}',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ]
                ),
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: const Divider()
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.mail_outlined,
                      color: Color.fromRGBO(100, 181, 246, 1),
                      size: 30,
                    ),
                    const SizedBox(width: 30),
                    SizedBox(
                      width: 250,
                      child: Text(
                        widget.user.email,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ]
                ),
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: const Divider()
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.assignment_ind,
                      color: Color.fromRGBO(100, 181, 246, 1),
                      size: 30,
                    ),
                    const SizedBox(width: 30),
                    SizedBox(
                      width: 250,
                      child: Text(
                        widget.user.role[0].toUpperCase() + widget.user.role.substring(1),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ]
                ),
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: const Divider()
                ),
                (widget.user.role == "patient") ? (
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.people_alt_outlined,
                            color: Color.fromRGBO(100, 181, 246, 1),
                            size: 30,
                          ),
                          const SizedBox(width: 30),
                          const SizedBox(
                            width: 190,
                            child: Text(
                              "My Therapists",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => showingTherapists = !showingTherapists ),
                            icon: showingTherapists ? const Icon(
                              Icons.arrow_drop_up,
                              color: Color.fromRGBO(100, 181, 246, 1),
                              size: 30,
                            ) : const Icon(
                              Icons.arrow_drop_down,
                              color: Color.fromRGBO(100, 181, 246, 1),
                              size: 30,
                            ),
                          )
                        ]
                      ),
                      Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: const Divider()
                      ),
                    ]
                  )
                ) : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(
                      Icons.visibility_outlined,
                      color: Color.fromRGBO(100, 181, 246, 1),
                      size: 30,
                    ),
                    SizedBox(width: 30),
                    SizedBox(
                      width: 250,
                      child: Text(
                        "Reset Password",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ]
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: () async {
                      print("pressed");
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.all(15),
                      ),
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) Phoenix.rebirth(context);
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.all(15),
                      ),
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
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
