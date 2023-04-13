import 'package:flutter/material.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/users/patient.dart';
import 'package:rehapp/model/users/therapist.dart';
import 'package:rehapp/pages/shared/login.dart';
import 'package:rehapp/pages/shared/verify_email.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);
  @override State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  Map<String, dynamic> userData = {"role": "patient"};
  String password = "";
  bool isApiCallProcess = false;
  bool isTherapist = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
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
            child: Form(
              key: globalFormKey,
              child: Column(
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: CREATE_AN_ACCOUNT,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    validator: (input) => input!.length > 1 ? null : FILL_OUT_NAME,
                    onSaved: (input) => userData["firstName"] = input!,
                    decoration: InputDecoration(
                      hintText: "First name",
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
                      prefixIcon: Icon(Icons.account_circle_outlined,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    validator: (input) => input!.length > 1 ? null : FILL_OUT_NAME,
                    onSaved: (input) => userData["lastName"] = input!,
                    decoration: InputDecoration(
                      hintText: "Last name",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2)
                          ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.account_circle_outlined,
                        color: Theme.of(context).colorScheme.secondary
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    validator: (input) => input!.contains("@") ? null : INVALID_EMAIL_MESSAGE,
                    onSaved: (input) => userData["email"] = input!,
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
                          color: Theme.of(context).colorScheme.secondary
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).colorScheme.secondary
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    validator: (input) => input!.length < 3 ? INVALID_PASSWORD_MESSAGE : null,
                    onSaved: (input) => password = input!,
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
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(ARE_YOU_THERAPIST),
                      Switch(
                          value: isTherapist,
                          onChanged: (bool newValue) {
                            setState(() {
                              isTherapist = newValue;
                            });
                            if (!newValue) {
                              userData["role"] = "patient";
                            } else {
                              userData["role"] = "therapist";
                            }
                          }),
                    ],
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 80),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      if (validateAndSave()) {
                        setState(() {
                          isApiCallProcess = true;
                        });
                        APIService apiService = APIService();
                        apiService.signup(
                          password,
                          (userData["role"] == "patient") ? Patient.fromJson(userData) : Therapist.fromJson(userData)
                        ).then((value) {
                          setState(() {
                            isApiCallProcess = false;
                          });
                          const snackBar = SnackBar(
                            content: Text(EMAIL_SUCCESS_SNACKBAR),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const VerifyEmailPage(nextPage: LoginPage())
                            ),
                          );
                        }).catchError((e) {
                          print(e);
                          setState(() {
                            isApiCallProcess = false;
                          });
                        });
                      }
                    },
                    child: const Text(
                      CREATE_ACCOUNT_BUTTON_TEXT,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ]
              ),
            ),
          ),
        ]),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
