import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/model/users/patient.dart';


class PatientHomePage extends StatefulWidget {
  final BuildContext buildContext;
  final Future<Assignment?> Function(Assignment) onPush;
  const PatientHomePage({Key? key, required this.buildContext, required this.onPush}) : super(key: key);
  @override State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  TextEditingController editingController = TextEditingController();
  final ScrollController controller = ScrollController();
  final TextEditingController textFieldController = TextEditingController();
  bool isApiCallProcess = true;
  APIService apiService = APIService();
  Patient user = Patient();

  String today = DateFormat('EEEE').format(DateTime.now());
  String todayDate = DateFormat('yMMMEd').format(DateTime.now());

  List<Assignment> allAssignments = [];
  List<Assignment> todaysAssignments = [];
  List<Assignment> otherAssignments = [];

  List<Assignment> filteredallAssignments = [];
  bool filtered = false;

  List<Assignment> prevallAssignments = [];
  List<Assignment> prevtodaysAssignments = [];
  List<Assignment> prevotherAssignments = [];

  Future<void> navigateAndUpdateAssignment(int index) async {
    Assignment selectedAssignment = (index < todaysAssignments.length) ? todaysAssignments.elementAt(index) : otherAssignments.elementAt(index - todaysAssignments.length);
    final updatedAssignment = await widget.onPush(selectedAssignment);
  
    if (!mounted) return;

    if (updatedAssignment != null) {
      if (index < todaysAssignments.length) {
        setState(() => todaysAssignments[index] = updatedAssignment);
      } else {
        setState(() => otherAssignments[index - todaysAssignments.length] = updatedAssignment);
      }
    }
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty && !query.contains("frequency")) {
      List<Assignment> filteredAssignments = [];
      for (Assignment assignment in allAssignments) {
        if (assignment.exerciseName.toLowerCase().contains(
            query.toLowerCase()) ||
            assignment.description.toLowerCase().contains(
                query.toLowerCase()) ||
            assignment.details.toLowerCase().contains(query.toLowerCase())) {
          filteredAssignments.add(assignment);
        }
      }
      setState(() {
        filtered = true;
        allAssignments.clear();
        todaysAssignments.clear();
        otherAssignments.clear();
        for (Assignment assignment in filteredAssignments) {
          if (assignment.frequency.contains(today)) {
            todaysAssignments.add(assignment);
          } else {
            otherAssignments.add(assignment);
          }
          allAssignments.add(assignment);
        }
      });
      return;
    } else if (query.isNotEmpty && query.contains("frequency")) {
      if (filtered) {
        filtered = false;
        allAssignments.clear();
        todaysAssignments.clear();
        otherAssignments.clear();
        allAssignments.addAll(prevallAssignments);
        todaysAssignments.addAll(prevtodaysAssignments);
        otherAssignments.addAll(prevotherAssignments);
      }
      filtered = true;
      Map filteredByFreq = Map<Assignment,int>();
      for (Assignment assignment in allAssignments) {
          print(assignment.exerciseName);
          print(assignment.frequency.length);
          filteredByFreq[assignment] = assignment.frequency.length;
       }
      print(filteredByFreq);
      var sortedByValueMap = Map.fromEntries(
          filteredByFreq.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)));
      print(sortedByValueMap);
      setState(() {
        filtered = true;
        allAssignments.clear();
        todaysAssignments.clear();
        otherAssignments.clear();
        for (Assignment assignment in sortedByValueMap.keys) {
          if (assignment.frequency.contains(today)) {
            todaysAssignments.add(assignment);
          } else {
            otherAssignments.add(assignment);
          }
          allAssignments.add(assignment);
        }
      });
      return;
    }
    else {
      setState(() {
        filtered = false;
        allAssignments.clear();
        todaysAssignments.clear();
        otherAssignments.clear();
        allAssignments.addAll(prevallAssignments);
        todaysAssignments.addAll(prevtodaysAssignments);
        otherAssignments.addAll(prevotherAssignments);
      });
    }
  }


  @override
  void initState() {
    apiService.getAssignments(FirebaseAuth.instance.currentUser!.uid)
      .then((value) {
        setState(() {
          allAssignments = value;
          todaysAssignments = value.where((assignment) => assignment.frequency.contains(today)).toList();
          otherAssignments = allAssignments.toSet().difference(todaysAssignments.toSet()).toList();
          isApiCallProcess = false;
        });
      })
      .catchError((error) {
        const snackBar = SnackBar(
          content: Text("Loading exercises failed"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() => isApiCallProcess = false);
      });
    apiService.getCurrentUser()
      .then((userValue) {
        user = userValue as Patient;
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Stack(
      children: <Widget>[
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Text(
                  'Welcome, ${user.firstName}',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
              Container(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: TextField(
                      // Search Bar
                        onChanged: (value) {
                          if (!filtered) {
                            prevtodaysAssignments.clear();
                            prevotherAssignments.clear();
                            prevallAssignments.clear();
                            for (Assignment assignment in allAssignments) {
                              if (assignment.frequency.contains(today)) {
                                prevtodaysAssignments.add(assignment);
                              } else {
                                prevotherAssignments.add(assignment);
                              }
                              prevallAssignments.add(assignment);
                            }
                          }

                          filterSearchResults(value);
                        },
                        controller: editingController,
                        decoration: const InputDecoration(
                          labelText: "Search",
                          hintText: "Search",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(25.0))
                          ),
                        )
                    ),
                  )
              ),
              Expanded(
                child: allAssignments.isEmpty ? const Center(
                  child: Text("Looks like you have no exercises assigned.")
                ) : RefreshIndicator(
                  displacement: 0.0,
                  onRefresh: () async {
                    await apiService.getAssignments(FirebaseAuth.instance.currentUser!.uid)
                      .then((value) {
                        setState(() {
                          allAssignments = value;
                            todaysAssignments = value.where((assignment) =>
                                assignment.frequency.contains(today)).toList();
                            otherAssignments =
                                allAssignments.toSet().difference(
                                    todaysAssignments.toSet()).toList();
                          isApiCallProcess = false;
                        });
                      })
                      .catchError((error) {
                        const snackBar = SnackBar(
                          content: Text("Loading exercises failed"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() => isApiCallProcess = false);
                      });
                  },
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    controller: controller,
                    itemCount: allAssignments.length,
                    itemBuilder: (context, index) => Column(
                      children: <Widget>[
                        (index == 0) ? Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                              child: const Text(
                                'Today\'s Exercises:',
                                style: TextStyle(fontSize: 20)
                              ),
                            ), (todaysAssignments.isEmpty) ? const SizedBox(
                              height: 50,
                              child: Center(
                                child: Text(
                                  "You have no exercises to perform today!",
                                )
                              )
                            ) : Container()
                          ]
                        ) : Container(),
                        (index == todaysAssignments.length) ? Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                              child: const Text(
                                'Other Assigned Exercises:',
                                style: TextStyle(fontSize: 20)
                              ),
                            ), (otherAssignments.isEmpty) ? const SizedBox(
                              height: 50,
                              child: Center(
                                child: Text("You have no other assigned exercises!")
                              )
                            ) : Container()
                          ]
                        ) : Container(),
                        Card(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          elevation: 3,
                          child: InkWell(
                            splashColor:Colors.blue.withAlpha(30),
                            onTap: () => navigateAndUpdateAssignment(index),
                            child: Column(
                              children: <Widget>[
                                (index < todaysAssignments.length) ? ListTile(
                                  title: Text(todaysAssignments.elementAt(index).exerciseName),
                                  subtitle: Text(todaysAssignments.elementAt(index).frequency.join(', ')),
                                  trailing: (todaysAssignments.elementAt(index).lastCompletedDate == todayDate) ? const Icon(
                                    Icons.check_circle
                                  ) : null,
                                ) : ListTile(
                                  title: Text(otherAssignments.elementAt(index - todaysAssignments.length).exerciseName),
                                  subtitle: Text(otherAssignments.elementAt(index - todaysAssignments.length).frequency.join(', ')),
                                  trailing: (otherAssignments.elementAt(index - todaysAssignments.length).lastCompletedDate == todayDate) ? const Icon(
                                    Icons.check_circle
                                  ) : null
                                )
                              ],
                            )
                          ),
                        )
                      ]
                    )
                  ),
                ),
              )
            ]),
          ),
        ),
      ],
    );
  }
}
