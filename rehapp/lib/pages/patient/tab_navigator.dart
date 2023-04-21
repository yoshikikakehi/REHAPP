import 'package:flutter/material.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/pages/patient/assignment.dart';
import 'package:rehapp/pages/patient/home.dart';

class PatientTabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const PatientTabNavigator({super.key, required this.navigatorKey});

  Future<Assignment?> _push(BuildContext context, Assignment assignment) async {
    var routeBuilders = _routeBuilders(context, assignment);

    final updatedAssignment = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => routeBuilders["/assignment"]!(context))
    );

    return updatedAssignment;
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, Assignment assignment) {
    return {
      "/": (context) => PatientHomePage(
        buildContext: context,
        onPush: (Assignment selectedAssignment) => _push(context, selectedAssignment)
      ),
      "/assignment": (context) => AssignmentPage(
        assignment: assignment
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context, Assignment());

    return Navigator(
      key: navigatorKey,
      initialRoute: "/",
      onGenerateRoute: (routeSettings) => MaterialPageRoute(builder: (context) => routeBuilders[routeSettings.name]!(context))
    );
  }
}