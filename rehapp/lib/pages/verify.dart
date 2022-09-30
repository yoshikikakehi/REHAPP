import 'package:flutter/material.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/verify_model.dart';
import 'package:rehapp/pages/login.dart';

import '../ProgressHUD.dart';

class VerifyPage extends StatefulWidget {
  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  late VerifyRequestModel requestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    requestModel = VerifyRequestModel();
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
                    text: VERIFY_TITLE,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (input) =>
                      input!.length > 1 ? null : FILL_OUT_CODE,
                  onSaved: (input) => requestModel.emailToken = input!,
                  decoration: InputDecoration(
                    hintText: "Enter your confirmation code here",
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
                    prefixIcon: Icon(Icons.assignment_outlined,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                const SizedBox(
                  height: 30,
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
                      apiService.verify(requestModel).then((value) {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        print('correct move man');
                        const snackBar = SnackBar(
                          content: Text(SIGNUP_SUCCESS_SNACKBAR),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }).catchError((onError) {
                        print(onError);
                        print('somehow you messed up');
                        const snackBar = SnackBar(
                          content: Text(CODE_FAILURE_SNACKBAR),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
