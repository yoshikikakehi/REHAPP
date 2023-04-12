import 'package:flutter/material.dart';
import 'package:rehapp/model/users/patient.dart';
import 'package:rehapp/model/users/therapist.dart';
import 'package:rehapp/pages/therapist/home.dart';
import 'package:rehapp/pages/therapist/patient_assignments.dart';

class TherapistTabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Therapist user;
  const TherapistTabNavigator({super.key, required this.user, required this.navigatorKey});

  void _push(BuildContext context, Patient patient) {
    var routeBuilders = _routeBuilders(context, patient);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => routeBuilders["/assignments"]!(context))
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, Patient patient) {
    return {
      "/": (context) => TherapistHomePage(
        buildContext: context,
        user: user,
        onPush: (Patient selectedPatient) => _push(context, selectedPatient)
      ),
      "/assignments": (context) => AssignmentsListPage(
        patient: patient
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context, Patient());

    return Navigator(
      key: navigatorKey,
      initialRoute: "/",
      onGenerateRoute: (routeSettings) => MaterialPageRoute(builder: (context) => routeBuilders[routeSettings.name]!(context))
    );
  }
}