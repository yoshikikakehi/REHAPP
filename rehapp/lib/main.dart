import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:rehapp/firebase_options.dart';
import 'package:rehapp/pages/shared/home.dart';
import 'package:rehapp/pages/shared/login.dart';

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
          displayLarge: TextStyle(fontSize: 22.0, color: Colors.blueAccent),
          displayMedium: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
            color: Colors.blueAccent,
          ),
          bodyLarge: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: Colors.blueAccent,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          )
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent).copyWith(error: Colors.red[700])
      ),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.emailVerified) ? (
          const HomePage()
         ) : (
          const LoginPage()
        )
      ),
    );
  }
}
