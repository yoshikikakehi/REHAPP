import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rehapp/firebase_options.dart';
import 'package:rehapp/pages/shared/login.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) => (snapshot.hasError) ? Scaffold(
        body: Center(
          child: Text(snapshot.error.toString())
        )
      ) : (snapshot.connectionState == ConnectionState.done) ? MaterialApp(
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
        home: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ),
          // child: (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.emailVerified) ? (
          child: LoginPage(),
        ),
      ) : Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        )
      )
    );
  }
}
