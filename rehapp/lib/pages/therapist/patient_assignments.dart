import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/model/users/patient.dart';
import 'package:rehapp/pages/therapist/assign_exercise.dart';
import 'package:rehapp/pages/therapist/assignment.dart';


class AssignmentsListPage extends StatefulWidget {
  final Patient patient;
  const AssignmentsListPage({Key? key, required this.patient}) : super(key: key);
  @override State<AssignmentsListPage> createState() => _AssignmentsListPageState();
}

class _AssignmentsListPageState extends State<AssignmentsListPage> {
  TextEditingController editingController = TextEditingController();
  final ScrollController _controller = ScrollController();
  bool isApiCallProcess = true;
  APIService apiService = APIService();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<Assignment> assignments = [];
  List<Assignment> displayedAssignments = [];

  @override
  void initState() {
    apiService
      .getAssignments(widget.patient.id)
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
      List<Assignment> filteredAssignments = [];
      for (Assignment assignment in assignments) {
        if (assignment.exerciseName.toLowerCase().contains(query.toLowerCase())) {
          filteredAssignments.add(assignment);
        }
      }
      setState(() {
        displayedAssignments.clear();
        displayedAssignments.addAll(filteredAssignments);
      });
    } else {
      setState(() {
        displayedAssignments.clear();
        displayedAssignments.addAll(assignments);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  Future<void> navigateAndAddAssignment(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AssignExercisePage(patient: widget.patient)),
    );

    if (!mounted) return;

    assignments.add(result);
    displayedAssignments.add(result);
    
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Assignment created!')));
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            title: Text(
              "${widget.patient.firstName}'s Exercises",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              IconButton(
                splashRadius: 25,
                iconSize: 30,
                onPressed: () => navigateAndAddAssignment(context),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.black
                )
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
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
                ),
                Expanded(
                  child: RefreshIndicator(
                    displacement: 0.0,
                    onRefresh: () async {
                      apiService.getAssignments(widget.patient.id).then((value) {
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
                    child: assignments.isEmpty ? Container(
                      alignment: Alignment.center,
                      child: Text(
                        "No exercises have been assigned to this patient yet",
                        style: TextStyle(
                          color: const Color(0x88888888).withOpacity(0.7),
                          fontSize: 16.0
                        )
                      ),
                    ) : displayedAssignments.isEmpty ? Container(
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
                              child: (displayedAssignments.elementAt(index).therapistId == FirebaseAuth.instance.currentUser!.uid) ? 
                                Card(
                                  margin: EdgeInsets.zero,
                                  color: Colors.grey[100],
                                  child: InkWell(
                                    splashColor:Colors.blue.withAlpha(30),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AssignmentPage(
                                          assignment: assignments.elementAt(index),
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(displayedAssignments.elementAt(index).exerciseName),
                                      subtitle: Text(displayedAssignments.elementAt(index).frequency.join(', ')),
                                      leading: const SizedBox(
                                        height: double.infinity,
                                        child: Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.black,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ) : Dismissible(
                                  key: Key(displayedAssignments.elementAt(index).id),
                                  background: Container(
                                    alignment: AlignmentDirectional.centerEnd,
                                    color: Colors.red,
                                    child: const Padding(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white
                                      )
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    apiService
                                      .deleteAssignment(widget.patient.id, displayedAssignments.elementAt(index).id)
                                      .then((value) {
                                        setState(() {
                                          assignments.removeAt(index);
                                          displayedAssignments.removeAt(index);
                                        });
                                      }).catchError((error) {
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
                                      splashColor:Colors.blue.withAlpha(30),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AssignmentPage(
                                            assignment: assignments.elementAt(index),
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        title: Text(displayedAssignments.elementAt(index).exerciseName),
                                        subtitle: Text(displayedAssignments.elementAt(index).frequency.join(', ')),
                                        leading: const SizedBox(
                                          height: double.infinity,
                                          child: Icon(
                                            Icons.check_circle_outline_rounded,
                                            color: Colors.black,
                                            size: 25,
                                          ),
                                        ),
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
    );
  }
}
