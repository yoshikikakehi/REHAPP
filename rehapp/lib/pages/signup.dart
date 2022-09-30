import 'package:flutter/material.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/signup_model.dart';
import 'package:rehapp/pages/login.dart';
import 'package:rehapp/pages/verify.dart';

import '../ProgressHUD.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  late SignupRequestModel requestModel;
  bool isApiCallProcess = false;
  bool isTherapist = false;

  @override
  void initState() {
    super.initState();
    requestModel = SignupRequestModel();
    requestModel.role = "patient";
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
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Container(
                width: double.infinity,
                alignment: Alignment.topLeft,
                child: BackButton()),
          ),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
            margin: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
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
                    text: CREATE_AN_ACCOUNT,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (input) =>
                      input!.length > 1 ? null : FILL_OUT_NAME,
                  onSaved: (input) => requestModel.firstname = input!,
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
                  validator: (input) =>
                      input!.length > 1 ? null : FILL_OUT_NAME,
                  onSaved: (input) => requestModel.lastname = input!,
                  decoration: InputDecoration(
                    hintText: "Last name",
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
                            requestModel.role = "patient";
                          } else {
                            requestModel.role = "therapist";
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
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    if (validateAndSave()) {
                      setState(() {
                        isApiCallProcess = true;
                      });
                      APIService apiService = APIService();
                      apiService.signup(requestModel).then((value) {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        print('is this correct?');
                        const snackBar = SnackBar(
                          content: Text(EMAIL_SUCCESS_SNACKBAR),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.pop(context);
                      }).catchError((onError) {
                        print(onError);
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
