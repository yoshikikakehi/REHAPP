import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/users/therapist.dart';
import 'package:rehapp/model/users/user.dart';
import 'package:rehapp/pages/shared/login.dart';
import 'package:rehapp/pages/shared/reset_password.dart';
import 'package:rehapp/pages/shared/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  final RehappUser user;
  final Image image;
  final Future<void> Function(dynamic) updateUser;
  const ProfilePage({Key? key, required this.user, required this.image, required this.updateUser}) : super(key: key);
  @override State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  APIService apiService = APIService();
  bool isApiCallProcess = true;
  bool showingTherapists = false;
  final List<Therapist> therapists = [];

  Future<void> navigateAndUpdateProfile() async {
    final newImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(user: widget.user)),
    );
    if (!mounted) return;
    await widget.updateUser(newImage);
  }

  @override
  void initState() {
    super.initState();
    if (widget.user.role == "patient") {
      apiService.getTherapists(widget.user.id)
        .then((value) => therapists.addAll(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 60),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Text(
                      '${widget.user.firstName} ${widget.user.lastName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      )
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color.fromARGB(188, 185, 185, 185),
                      child: (widget.user.profileImage != null && widget.user.profileImage!.isNotEmpty) ? ClipRRect(
                        borderRadius: BorderRadius.circular(115),
                        child: widget.image,
                      ) : const CircleAvatar(
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
            (widget.user.phoneNumber != null && widget.user.phoneNumber!.isNotEmpty) ? Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.phone,
                      color: Color.fromRGBO(100, 181, 246, 1),
                      size: 30,
                    ),
                    const SizedBox(width: 30),
                    SizedBox(
                      width: 250,
                      child: Text(
                        widget.user.phoneNumber!,
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
              ]
            ) : Container(),
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
                      const SizedBox(width: 30),
                      SizedBox(
                        height: 30.0,
                        width: 30.0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          splashRadius: 24,
                          onPressed: () => setState(() => showingTherapists = !showingTherapists ),
                          icon: showingTherapists ? const Icon(
                            Icons.arrow_drop_up,
                            color: Color.fromRGBO(100, 181, 246, 1),
                          ) : const Icon(
                            Icons.arrow_drop_down,
                            color: Color.fromRGBO(100, 181, 246, 1),
                          ),
                        )
                      )
                    ]
                  ),
                  showingTherapists ? Container(
                    alignment: Alignment.topCenter,
                    height: 90.0,
                    child: ListView(
                      children: therapists.map((therapist) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "${therapist.firstName} ${therapist.lastName} (${therapist.email})",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        )
                      )).toList()
                    )
                  ) : const SizedBox(height: 0),
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
              children: <Widget>[
                const Icon(
                  Icons.visibility_outlined,
                  color: Color.fromRGBO(100, 181, 246, 1),
                  size: 30,
                ),
                const SizedBox(width: 30),
                const SizedBox(
                  width: 190,
                  child: Text(
                    "Reset Password",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                SizedBox(
                  height: 30.0,
                  width: 30.0,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 24,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetPasswordPage(user: widget.user))
                    ),
                    icon: const Icon(
                      Icons.refresh_outlined,
                      color: Color.fromRGBO(100, 181, 246, 1),
                      size: 30,
                    ),
                  ),
                ),
              ]
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () => navigateAndUpdateProfile(),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.all(15),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
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
            const SizedBox(height: 15),
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              width: 100,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                    const snackBar = SnackBar(
                      content: Text("Logout Successful"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.all(15),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
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
      )
    );
  }
}
