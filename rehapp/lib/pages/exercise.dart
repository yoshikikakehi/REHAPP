import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/delete_exercise_model.dart';
import 'package:rehapp/model/exercise_model.dart';
import 'package:rehapp/pages/assign_exercise.dart';
import 'package:rehapp/pages/login.dart';
import 'package:rehapp/pages/logout.dart';
import 'package:rehapp/pages/therapist_completed_exercise.dart';
import 'package:rehapp/pages/therapist_exercise_view.dart';

import '../ProgressHUD.dart';

class ExercisePage extends StatefulWidget {
  final Map<String, dynamic> patient;

  const ExercisePage({Key? key, required this.patient}) : super(key: key);

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  TextEditingController editingController = TextEditingController();
  final ScrollController _controller = ScrollController();
  // GlobalKey<ScaffoldState> _scaffoldKey =
  //     GlobalKey<ScaffoldState>(); // used for the hamburger menu
  final TextEditingController _textFieldController = TextEditingController();
  bool isApiCallProcess = true;
  APIService apiService = APIService();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<dynamic> assignments = [];
  List<dynamic> displayedAssignments = [];

  int selectedPage = 1;
  final _pageOptions = [
    ExercisePage(patient: Map<String, dynamic>()),
    ExercisePage(patient: Map<String, dynamic>()),
    LogoutPage(),
  ];

  @override
  void initState() {
    apiService
      .getAssignments(widget.patient["id"], auth.currentUser?.uid)
      .then((value) {
        setState(() {
          assignments.addAll(value);
          displayedAssignments.addAll(value);
          isApiCallProcess = false;
        });
      }).catchError((error) {
        const snackBar = SnackBar(
          content: Text("Loading exercises failed"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          isApiCallProcess = false;
        });
      });
    super.initState();
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<dynamic> filteredAssignments = [];
      for (var assignment in assignments) {
        if (assignment["exerciseName"].contains(query)) {
          filteredAssignments.add(assignment);
        }
      }
      setState(() {
        displayedAssignments.clear();
        displayedAssignments.addAll(filteredAssignments);
      });
      return;
    } else {
      setState(() {
        displayedAssignments.clear();
        displayedAssignments.addAll(assignments);
      });
    }
  }

  String codeDialog = "";
  String valueText = "";

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPage,
        onTap: (index) {
          setState(() {
            selectedPage = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined), label: 'Account'),
        ],
      ),
      body: selectedPage != 2
          ? Stack(
              children: <Widget>[
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: <Widget>[
                      Container(
                        height: 90,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${widget.patient["firstName"]}\'s Exercises',
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold
                                      )
                                  )
                                  // Row(
                                  //   children: [
                                  //     const Text('Exercises:',
                                  //         style: TextStyle(fontSize: 20)),
                                  //     const SizedBox(width: 15),
                                  //     OutlinedButton(
                                  //       onPressed: () => Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //           builder: (context) => TherapistCompletedExercisePage(
                                  //             patient: widget.patient,
                                  //             completedExercises: [],
                                  //           )
                                  //         )
                                  //       ),
                                  //       child: const Text("Completed Exercises"),
                                  //     )
                                  //   ],
                                  // ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  IconButton(
                                      iconSize: 35,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AssignExercisePage(patient: widget.patient),
                                        )
                                      ),
                                      icon: const Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: Colors.black
                                      )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: TextField(
                          // Search Bar
                            onChanged: (value) {
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
                        child: RefreshIndicator(
                          displacement: 0.0,
                          onRefresh: () async {
                            apiService.getAssignments(widget.patient["id"], auth.currentUser?.uid).then((value) {
                              setState(() {
                                assignments.clear();
                                displayedAssignments.clear();
                                assignments.addAll(value);
                                displayedAssignments.addAll(value);
                              });
                            }).catchError((error) {
                              const snackBar = SnackBar(
                                content: Text("Loading exercises failed"),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            });
                          },
                          child: assignments.length == 0 ? Container(
                            alignment: Alignment.center,
                            child: Text(
                              "No exercises have been assigned to this patient yet",
                              style: TextStyle(
                                color: const Color(0x88888888).withOpacity(0.7),
                                fontSize: 16.0
                              )
                            ),
                          ) : displayedAssignments.length == 0 ? Container(
                            alignment: Alignment.center,
                            child: Text(
                              "No exercises to view",
                              style: TextStyle(
                                color: const Color(0x88888888).withOpacity(0.7),
                                fontSize: 16.0
                              )
                            ),
                          ) : ListView.builder(
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              controller: _controller,
                              itemCount: displayedAssignments.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Dismissible(
                                      key: Key('${displayedAssignments.elementAt(index)["exerciseName"]}'),
                                      background: Container(
                                        alignment:
                                            AlignmentDirectional.centerEnd,
                                        color: Colors.red,
                                        child: const Padding(
                                            padding:
                                                EdgeInsets.only(right: 10.0),
                                            child: Icon(Icons.delete,
                                                color: Colors.white)),
                                      ),
                                      onDismissed: (direction) {
                                        apiService
                                          .deleteAssignment(widget.patient["id"], displayedAssignments.removeAt(index)["id"])
                                          .then((value) {
                                            setState(() {
                                              assignments.removeAt(index);
                                              displayedAssignments.removeAt(index);
                                            });
                                          }).catchError((error) {
                                            print(error);
                                            const snackBar = SnackBar(
                                              content: Text("Deleting exercise failed"),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          });
                                      },
                                      confirmDismiss: (direction) async {
                                        return await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              Widget noButton = TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text("No"),
                                              );
                                              Widget yesButton = TextButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text("Yes"),
                                              );
                                              return AlertDialog(
                                                title: const Text("Delete exercise?"),
                                                content: const Text("Do you want to remove this exercise from this patient?"),
                                                actions: [noButton, yesButton],
                                              );
                                            });
                                      },
                                      direction: DismissDirection.endToStart,
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        child: InkWell(
                                          splashColor:
                                              Colors.blue.withAlpha(30),
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TherapistExercisePage(
                                                exercise: assignments.elementAt(index),
                                              ),
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text(displayedAssignments.elementAt(index)["exerciseName"]),
                                            subtitle: Text(displayedAssignments.elementAt(index)["frequency"].join(', ')),
                                            leading: Container(
                                              height: double.infinity,
                                              child: assignments.elementAt(index)["completed"] ? 
                                                const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Colors.blue,
                                                  size: 25,
                                                ) : const Icon(
                                                  Icons.check_circle_outline_rounded,
                                                  color: Colors.black,
                                                  size: 25,
                                                ),
                                            ),
                                            // trailing: assignments.elementAt(index)["completed"] ?
                                            //   const Icon(
                                            //     Icons.contact_mail_outlined,
                                            //     color: Colors.black)
                                            //   : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            )
          : LogoutPage(),
    );
  }
}
