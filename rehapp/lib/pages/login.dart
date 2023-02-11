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

bool checked = false;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  late LoginRequestModel requestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    requestModel = LoginRequestModel();
    transferLogin();
  }

  void transferLogin() async {
    if (FirebaseAuth.instance.currentUser != null) {
      if (user.role == "therapist") {
        Future.delayed(Duration.zero, () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TherapistHomePage()));
        });
      } else {
        Future.delayed(Duration.zero, () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
    );
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
                const SizedBox(
                  height: 25,
                ),
                RichText(
                  text: TextSpan(
                    text: LOGIN_TO,
                    style: Theme.of(context).textTheme.headline2,
                    children: const <TextSpan>[
                      TextSpan(
                        text: APP_NAME,
                        style: TextStyle(fontWeight: FontWeight.w900),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
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
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  onSaved: (input) => requestModel.password = input!,
                  validator: (input) =>
                      input!.length < 3 ? INVALID_PASSWORD_MESSAGE : null,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
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
                    prefixIcon: Icon(Icons.lock_outlined,
                        color: Theme.of(context).colorScheme.secondary),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
                      icon: Icon(hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                ),
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
                  onPressed: () {
                    if (validateAndSave()) {
                      setState(() {
                        isApiCallProcess = true;
                      });
                      APIService apiService = APIService();
                      apiService.login(requestModel).then((userCredential) async {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        if (userCredential.user != null) {
                          FirebaseFirestore.instance
                            .collection("users")
                            .doc(userCredential.user?.uid)
                            .get().then(
                              (DocumentSnapshot doc) async {
                                final data = doc.data() as Map<String, dynamic>;
                                user.firstname = data?["firstname"];
                                user.lastname = data["lastname"];
                                user.role = data["role"];
                                user.email = data["email"];
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setBool("isLoggedIn", true);
                                prefs.setString("firstname", data["firstname"]);
                                prefs.setString("lastname", data["lastname"]);
                                prefs.setString("role", data["role"]);
                                prefs.setString("email", data["email"]);
                                const snackBar = SnackBar(
                                  content: Text(LOGIN_SUCCESS_SNACKBAR),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                if (data["role"] == "therapist") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const TherapistHomePage()));
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()));
                                }
                              },
                              onError: (e) => print("Error getting document: $e"),
                            );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failure"),
                            )
                          );
                        }
                      }).catchError((onError) {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        const snackBar = SnackBar(
                          content: Text("Login failed"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                      print(requestModel.toJson());
                    }
                  },
                  child: const Text(
                    LOGIN_BUTTON_TEXT,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  //padding: const EdgeInsets.only(left: 370),
                  padding: const EdgeInsets.symmetric(
                      vertical: 0, horizontal: 215),
                  child: Material(
                    child: CheckboxListTile(
                      tileColor: Colors.white,
                      title: const Text('Remember me'),
                      controlAffinity: ListTileControlAffinity.platform,
                      selected: false,
                      value: checked,
                      onChanged:(bool? value) {
                        setState(() {
                          checked = value!;
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()));
                      },
                      child: RichText(
                        text: TextSpan(
                          text: DONT_HAVE_ACCOUNT,
                          style: Theme.of(context).textTheme.bodyText2,
                          children: const <TextSpan>[
                            TextSpan(
                                text: CREATE_ONE_NOW,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),

                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      print(requestModel);
      form.save();
      return true;
    }
    return false;
  }
}
