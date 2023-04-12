import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/pages/home.dart';
import 'package:rehapp/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    APIService apiService = APIService();
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   systemNavigationBarColor: Colors.transparent,
    // ));
    return MaterialApp(
      title: 'Rehapp',
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
        child: (FirebaseAuth.instance.currentUser != null) ? (
          const HomePage()
         ) : (
          LoginPage()
        )
      ),
    );
  }
}
