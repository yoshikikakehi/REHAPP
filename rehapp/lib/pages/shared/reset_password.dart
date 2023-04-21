import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/users/user.dart';

class ResetPasswordPage extends StatefulWidget {
  final RehappUser user;
  const ResetPasswordPage({Key? key, required this.user}) : super(key: key);
  @override State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isApiCallProcess = true;
  APIService apiService = APIService();

  bool differentNewPassword = false;
  bool hideOldPassword = true;
  bool hideNewPassword = true;
  bool hideReenteredNewPassword = true;
  String oldPassword = "";
  String newPassword = "";
  String reenteredNewPassword = "";
  
  Future<void> resetPassword(String oldPassword, String newPassword) async {
    User user = FirebaseAuth.instance.currentUser!;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email!,
        password: oldPassword,
      );
      user.updatePassword(newPassword).then((_) {
        const snackBar = SnackBar(content: Text("Successfully changed password"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        globalFormKey.currentState!.reset();
        Navigator.pop(context);
      });
    } on Exception catch(_) {
      const snackBar = SnackBar(content: Text("Password could not be changed"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 48),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: const BackButton()
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                        text: "Reset Password",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: (input) => input!.isEmpty ? "Please enter your old password" : null,
                      onSaved: (input) => setState(() => oldPassword = input!),
                      obscureText: hideOldPassword,
                      decoration: InputDecoration(
                        hintText: "Old Password",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2)
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        ),
                        prefixIcon: Icon(Icons.lock_outlined,color: Theme.of(context).colorScheme.secondary),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => hideOldPassword = !hideOldPassword);
                          },
                          color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.4),
                          icon: Icon(hideOldPassword ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: (input) => input!.isEmpty ? "Please enter your new password" : (input.length < 6) ? "Your new password must be at least 6 characters" : null,
                      onSaved: (input) => setState(() => newPassword = input!),
                      obscureText: hideNewPassword,
                      decoration: InputDecoration(
                        hintText: "New Password",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2)
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        ),
                        prefixIcon: Icon(Icons.lock_outlined,color: Theme.of(context).colorScheme.secondary),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => hideNewPassword = !hideNewPassword);
                          },
                          color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.4),
                          icon: Icon(hideNewPassword ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: (input) => (input!.isEmpty) ? "Please reenter your new password" : (differentNewPassword) ? "Passwords do not match" : null,
                      onSaved: (input) => setState(() => reenteredNewPassword = input!),
                      obscureText: hideReenteredNewPassword,
                      decoration: InputDecoration(
                        hintText: "Reenter New Password",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2)
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: Theme.of(context).colorScheme.secondary
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => hideReenteredNewPassword = !hideReenteredNewPassword);
                          },
                          color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.4),
                          icon: Icon(hideReenteredNewPassword ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () async {
                        if (validateAndSave()) {
                          setState(() => isApiCallProcess = true);
                          await resetPassword(oldPassword, newPassword);
                        }
                      },
                      child: const Text(
                        "Reset Password",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ]
                ),
              )
            )
          ]
        )
      )
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      if (newPassword != reenteredNewPassword) {
        setState(() => differentNewPassword = true);
        return false;
      }
      setState(() => differentNewPassword = false);
      return true;
    }
    return false;
  }
}