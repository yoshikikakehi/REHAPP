import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:rehapp/pages/home.dart';
import 'package:rehapp/pages/login.dart';
import 'package:rehapp/pages/therapist_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/token.dart' as token;
import '../api/user.dart' as user;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool status = prefs.getBool('isLoggedIn') ?? false;
  if (status) {
    double time = (DateTime.now()).millisecondsSinceEpoch / 1000;
    double? endTime = prefs.getDouble('logoutTime');
    if (endTime != null && endTime > time) {
      user.firstname = (prefs.getString('firstname'))!;
      user.lastname = (prefs.getString('lastname'))!;
      user.role = (prefs.getString('role'))!;
      user.email = (prefs.getString('email'))!;
      token.value = (prefs.getString('token'))!;
    } else {
      await prefs.clear();
    }
  } else {
    await prefs.clear();
  }
  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   systemNavigationBarColor: Colors.transparent,
    // ));
    return MaterialApp(
      title: 'Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'AtkinsonHyperlegible',
          primaryColor: Colors.white,
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
              headline1: TextStyle(fontSize: 22.0, color: Colors.blueAccent),
              headline2: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
              bodyText1: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.blueAccent,
              ),
              bodyText2: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              )),
          errorColor: Colors.red[700],
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent)),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: LoginPage(),
      ),
    );
  }
}
