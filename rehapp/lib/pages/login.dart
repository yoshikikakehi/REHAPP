import 'package:flutter/material.dart';

import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/pages/home.dart';
import 'package:rehapp/pages/signup.dart';

import '../ProgressHUD.dart';

bool checked = false;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  bool isApiCallProcess = false;

  String email = "";
  String password = "";

  APIService apiService = APIService();

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
                      offset: const Offset(0, 10),
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
                    style: Theme.of(context).textTheme.headlineMedium,
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
                  validator: (input) => input!.contains("@") ? null : INVALID_EMAIL_MESSAGE,
                  onSaved: (input) => setState(() => email = input!),
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
                  onSaved: (input) => setState(() => password = input!),
                  validator: (input) =>
                      input!.length < 6 ? INVALID_PASSWORD_MESSAGE : null,
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
                  ),
                  onPressed: () {
                    if (validateAndSave()) {
                      setState(() {
                        isApiCallProcess = true;
                      });
                      apiService.login(email, password).then((userCredential) async {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        if (userCredential.user != null) {
                          apiService.getCurrentUser()
                            .then((user) {
                              const snackBar = SnackBar(
                                content: Text(LOGIN_SUCCESS_SNACKBAR),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HomePage())
                              );
                            });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failure"))
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
                    }
                  },
                  child: const Text(
                    LOGIN_BUTTON_TEXT,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
               /* Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                  alignment: Alignment.center,
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
                ),*/
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
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: const <TextSpan>[
                          TextSpan(
                              text: CREATE_ONE_NOW,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ),
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
      form.save();
      return true;
    }
    return false;
  }
}
