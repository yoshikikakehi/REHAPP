import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/main.dart';
import 'package:rehapp/pages/exercise.dart';
import 'package:rehapp/pages/logout.dart';

class TherapistHomePage extends StatefulWidget {
  const TherapistHomePage({Key? key}) : super(key: key);

  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  TextEditingController editingController = TextEditingController();
  final ScrollController _controller = ScrollController();
  //GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // used for the hamburger menu
  final TextEditingController _textFieldController = TextEditingController();
  bool isApiCallProcess = true;
  APIService apiService = APIService();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  int selectedPage = 1;
  final _pageOptions = [
    TherapistHomePage(),
    TherapistHomePage(),
    LogoutPage(),
  ];

  List<dynamic> patients = [];
  List<dynamic> displayedPatients = [];
  Map<String, dynamic> user = {
    'firstName': '',
    'lastName': '',
    'email': '',
    'assignments': [],
    'role': "therapist",
    'patients': []
  };

  @override
  void initState() {
    apiService.getCurrentUserData()
      .then((userValue) {
        setState(() {
          user.addAll(userValue);
        });
        apiService.getPatients(userValue["patients"])
          .then((value) {
            if (mounted) {
              setState(() {
                patients.addAll(value);
                displayedPatients.addAll(value);
                isApiCallProcess = false;
              });
            }
          }).catchError((error) {
            const snackBar = SnackBar(
              content: Text("Loading patients failed"),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              isApiCallProcess = false;
            });
          });
      })
      .catchError((error) {
        const snackBar = SnackBar(
          content: Text("Loading current user failed"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          isApiCallProcess = false;
        });
      });
    super.initState();
  }

  void filterSearchResults(String query) {
    // Implementation for Search Bar
    if (query.isNotEmpty) {
      List<dynamic> filteredPatients = [];
      for (var patient in patients) {
        String fullName = patient["firstName"] + " " + patient["lastName"];
        if (fullName.contains(query)) {
          filteredPatients.add(patient);
        }
      }
      setState(() {
        displayedPatients.clear();
        displayedPatients.addAll(filteredPatients);
      });
      return;
    } else {
      setState(() {
        displayedPatients.clear();
        displayedPatients.addAll(patients);
      });
    }
  }

// Add patient pop up
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: this.context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Add Patient"),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  addPatientEmail = value;
                });
              },
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Patient Email"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    _textFieldController.clear();
                  });
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                  apiService
                    .addPatient(addPatientEmail, user["patients"])
                    .then((patient) {
                      const snackBar = SnackBar(
                        content: Text("Adding patient succeeded"),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      setState(() {
                        patients.add(patient);
                        displayedPatients.add(patient);
                        user.update("patients", (value) {
                          value.add(patient["id"]);
                          return value;
                        });
                        Navigator.pop(context);
                        _textFieldController.clear();
                      });
                    }).catchError((error) {
                      var snackBar = SnackBar(
                        content: Text(error.toString()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      setState(() {
                        Navigator.pop(context);
                        _textFieldController.clear();
                      });
                    });
                },
              ),
            ],
          );
        });
  }

  String addPatientEmail = "";

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
    );
  }

  @override
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
      body: selectedPage != 2 ? Stack(
              children: <Widget>[
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
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
                                  Text("Hi " + user["firstName"],
                                      style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold)),
                                  const Text('Here are your patients:',
                                      style: TextStyle(fontSize: 20)),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  IconButton(
                                    iconSize: 35,
                                    onPressed: () => {_displayTextInputDialog(context)},
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: Colors.black,
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0))),
                            )),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          displacement: 0.0,
                          onRefresh: () async {
                            await apiService.getPatients(user["patients"]).then((value) {
                              setState(() {
                                patients.clear();
                                displayedPatients.clear();
                                patients.addAll(value);
                                displayedPatients.addAll(value);
                              });
                            }).catchError((error) {
                              print(error);
                              const snackBar = SnackBar(
                                content: Text("Retrieving patients failed"),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            });
                          },
                          child: user["patients"].length == 0 ? Container(
                            alignment: Alignment.center,
                            child: Text(
                              "No patients have been added yet",
                              style: TextStyle(
                                color: const Color(0x88888888).withOpacity(0.7),
                                fontSize: 16.0
                              )
                            ),
                          ) : ListView.builder(
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              controller: _controller,
                              itemCount: displayedPatients.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Dismissible(
                                      key: Key(displayedPatients.elementAt(index)["email"]),
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
                                        apiService.deletePatient(user["patients"].elementAt(index))
                                          .then((value) {
                                            setState(() {
                                              displayedPatients.removeAt(index);
                                              patients.removeAt(index);
                                              user.update("patients", (value) {
                                                value.removeAt(index);
                                                return value;
                                              });
                                            });
                                          }).catchError((error) {
                                            print(error);
                                            const snackBar = SnackBar(
                                              content:
                                                  Text("Deleting patient failed"),
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
                                                    "Delete patient?"),
                                                content: const Text(
                                                    "Do you want to remove this patient from your roster?"),
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
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ExercisePage(patient: displayedPatients.elementAt(index))
                                              )
                                            );
                                          },
                                          child: ListTile(
                                            title: Text(displayedPatients.elementAt(index)["firstName"] + " " + displayedPatients.elementAt(index)["lastName"]),
                                            subtitle: Text(displayedPatients.elementAt(index)["email"]),
                                            leading: Container(
                                              height: double.infinity,
                                              child: const Icon(
                                                Icons.account_circle_outlined,
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
          : LogoutPage(),
    );
  }
}
