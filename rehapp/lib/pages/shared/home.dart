import 'package:flutter/material.dart';

import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/users/therapist.dart';
import 'package:rehapp/model/users/user.dart';
import 'package:rehapp/pages/patient/tab_navigator.dart';
import 'package:rehapp/pages/shared/profile.dart';
import 'package:rehapp/pages/therapist/tab_navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  APIService apiService = APIService();
  final navigatorKey = GlobalKey<NavigatorState>();
  RehappUser? user;
  int selectedIndex = 0;

  @override
  void initState() {
    apiService.getCurrentUser().then((userValue) {
      setState(() {
        user = userValue;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: false,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  void onTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _uiSetup(BuildContext context) {
    return (user == null) ? (
      const Center(
        child: CircularProgressIndicator(),
      )
    ) : (user!.role == "patient") ? (
      Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          unselectedItemColor: Colors.grey.withAlpha(200),
          selectedItemColor: Colors.blue,
          onTap: onTap,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: 'Profile'),
          ],
        ),
        body: (selectedIndex == 0) ? (
          PatientTabNavigator(
            navigatorKey: navigatorKey
          )
        ) : (
          ProfilePage(user: user!)
        )
      )
    ) : (
     Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          unselectedItemColor: Colors.grey.withAlpha(200),
          selectedItemColor: Colors.blue[800],
          onTap: onTap,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.stacked_line_chart_rounded), label: 'Statistics'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: 'Profile'),
          ],
        ),
        body: (selectedIndex == 0) ? (
          TherapistTabNavigator(
            user: user as Therapist,
            navigatorKey: navigatorKey,
          )
        ) : (
          ProfilePage(user: user!)
        )
      )
    );
  }
}