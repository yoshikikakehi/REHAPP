import 'package:flutter/material.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/delete_exercise_model.dart';
import 'package:rehapp/model/exercise_model.dart';
import 'package:rehapp/pages/assign_exercise.dart';
import 'package:rehapp/pages/login.dart';
import 'package:rehapp/pages/logout.dart';
import 'package:rehapp/pages/therapist_exercise_view.dart';

import '../ProgressHUD.dart';

class TherapistCompletedExercisePage extends StatefulWidget {
  final Map<String, dynamic> patient;
  List<Exercise> completedExercises;

  TherapistCompletedExercisePage(
      {Key? key, required this.patient, required this.completedExercises})
      : super(key: key);

  @override
  _TherapistCompletedExercisePageState createState() =>
      _TherapistCompletedExercisePageState();
}

class _TherapistCompletedExercisePageState
    extends State<TherapistCompletedExercisePage> {
  TextEditingController editingController = TextEditingController();
  final ScrollController _controller = ScrollController();
  // GlobalKey<ScaffoldState> _scaffoldKey =
  //     GlobalKey<ScaffoldState>(); // used for the hamburger menu
  final TextEditingController _textFieldController = TextEditingController();
  bool isApiCallProcess = false;
  List<Exercise> items = [];

  int selectedPage = 1;
  final _pageOptions = [
    TherapistCompletedExercisePage(
      patient: Map<String, dynamic>(),
      completedExercises: [],
    ),
    TherapistCompletedExercisePage(
      patient: Map<String, dynamic>(),
      completedExercises: [],
    ),
    LogoutPage(),
  ];

  @override
  void initState() {
    items.addAll(widget.completedExercises);
    super.initState();
  }

  void filterSearchResults(String query) {
    // Implementation for Search Bar
    List<Exercise> nameSearchList = [];
    nameSearchList.addAll(widget.completedExercises);
    print(nameSearchList);
    if (query.isNotEmpty) {
      List<Exercise> nameData = [];
      for (var item in nameSearchList) {
        if (item.exerciseName.contains(query)) {
          nameData.add(item);
        }
      }
      setState(() {
        items.clear();
        items.addAll(nameData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(widget.completedExercises);
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
                        height: 85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Completed Exercises',
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold)),
                                OutlinedButton(
                                  child: const Text("Uncomplete Exercises"),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                IconButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AssignExercisePage(
                                                  patient: widget.patient),
                                        )),
                                    icon: const Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: Colors.black)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextField(
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0))),
                          )),
                      Expanded(
                        child: RefreshIndicator(
                          displacement: 0.0,
                          onRefresh: () async {
                            APIService apiService = APIService();
                            await apiService
                                .getExercises(widget.patient["email"])
                                .then((value) {
                              setState(() {
                                widget.completedExercises.clear();
                                items.clear();
                                for (Exercise e in value.exercises) {
                                  if (e.exerciseStatus == "COMPLETED") {
                                    widget.completedExercises.add(e);
                                    items.add(e);
                                  }
                                }
                              });
                              isApiCallProcess = false;
                            }).catchError((error) {
                              const snackBar = SnackBar(
                                content: Text("Loading exercises failed"),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            });
                          },
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              controller: _controller,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Dismissible(
                                      // Swiping to remove a patient
                                      key: Key('${items[index].exerciseID}'),
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
                                        APIService apiService = APIService();
                                        apiService
                                            .deleteExercises(
                                                DeleteExerciseRequestModel(
                                                    exerciseID: widget
                                                        .completedExercises[
                                                            index]
                                                        .exerciseID))
                                            .then((value) {
                                          setState(() {
                                            items.removeAt(index);
                                            widget.completedExercises
                                                .removeAt(index);
                                          });
                                        }).catchError((error) {
                                          print(error);
                                          const snackBar = SnackBar(
                                            content: Text(
                                                "Deleting exercise failed"),
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
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text("No"),
                                              );
                                              Widget yesButton = TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text("Yes"),
                                              );
                                              return AlertDialog(
                                                title: const Text(
                                                    "Delete exercise?"),
                                                content: const Text(
                                                    "Do you want to remove this exercise from this patient?"),
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
                                              builder: (context) =>
                                                  TherapistExercisePage(
                                                exercise: widget
                                                    .completedExercises[index],
                                              ),
                                            ),
                                          ),
                                          child: ListTile(
                                            title:
                                                Text(items[index].exerciseName),
                                            subtitle: Text(
                                                items[index].exerciseFrequency),
                                            leading: widget
                                                        .completedExercises[
                                                            index]
                                                        .exerciseStatus ==
                                                    "ASSIGNED"
                                                ? const Icon(
                                                    Icons.note_alt_outlined,
                                                    color: Colors.black)
                                                : const Icon(
                                                    Icons
                                                        .check_circle_outline_rounded,
                                                    color: Colors.black),
                                            trailing: widget
                                                        .completedExercises[
                                                            index]
                                                        .exerciseStatus ==
                                                    "COMPLETED"
                                                ? const Icon(
                                                    Icons.contact_mail_outlined,
                                                    color: Colors.black)
                                                : null,
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
