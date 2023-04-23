import 'package:flutter/material.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/model/users/user.dart';  
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final RehappUser user;
  const CalendarPage({super.key, required this.user});
  @override State<CalendarPage> createState() => _CalendarPageState();  
}  
  
class _CalendarPageState extends State<CalendarPage> {  
  APIService apiService = APIService();
  bool isApiCallProcess = true;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  Map<String, List<Assignment>> events = {};
  final List<String> daysOfWeek = ["", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  @override  
  void initState() {
    super.initState();

    apiService
      .getAssignments(widget.user.id)
      .then((value) {
        for (Assignment assignment in value) {
          for (String day in assignment.frequency) {
            if (events[day] == null) {
              events[day] = [assignment];
            } else {
              events[day]!.add(assignment);
            }
          }
        }
        setState(() => isApiCallProcess = false);
      });
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context)
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TableCalendar(
            locale: "en_US",
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            focusedDay: focusedDay,
            firstDay: DateTime.now().subtract(const Duration(days: 3650)),
            lastDay: DateTime.now().add(const Duration(days: 3650)),
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },
            eventLoader: (day) {
              return events[daysOfWeek[day.weekday]] ?? [];
            },
          ),
          Container(
            height: 255,
            padding: const EdgeInsets.only(top: 24, bottom: 12, left: 24, right: 24),
            child: ListView(
              children: (events[daysOfWeek[selectedDay.weekday]] != null) ?
                events[daysOfWeek[selectedDay.weekday]]!.map((assignment) => Card(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    title: Text(assignment.exerciseName),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Frequency: ${assignment.frequency.join(', ')}", textAlign: TextAlign.start,),
                        Text("Expected Duration: ${assignment.duration} min", textAlign: TextAlign.start,),
                      ]
                    )
                  )
                )).toList() : [Container()]
            )
          )
        ]
      )
    );
  }
}  
