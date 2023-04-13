import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/users/patient.dart';
import 'package:rehapp/model/users/therapist.dart';
import 'package:rehapp/model/users/user.dart';

class TherapistHomePage extends StatefulWidget {
  final BuildContext buildContext;
  final Therapist user;
  final ValueChanged<Patient> onPush;
  const TherapistHomePage({Key? key, required this.buildContext, required this.user, required this.onPush}) : super(key: key);

  @override State<TherapistHomePage> createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  TextEditingController editingController = TextEditingController();
  final ScrollController _controller = ScrollController();
  final TextEditingController _textFieldController = TextEditingController();
  bool isApiCallProcess = true;

  APIService apiService = APIService();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<Patient> patients = [];
  List<Patient> displayedPatients = [];

  @override
  void initState() {
    apiService.getPatients(widget.user.patients)
      .then((value) {
        setState(() {
          patients.addAll(value);
          displayedPatients.addAll(value);
          isApiCallProcess = false;
        });
      }).catchError((error) {
        const snackBar = SnackBar(
          content: Text("Loading patients failed"),
        );
        ScaffoldMessenger.of(widget.buildContext).showSnackBar(snackBar);
        setState(() {
          isApiCallProcess = false;
        });
      });
    super.initState();
  }

  void filterSearchResults(String query) {
    // Implementation for Search Bar
    if (query.isNotEmpty) {
      List<Patient> filteredPatients = [];
      for (var patient in patients) {
        String fullName = "${patient.firstName} ${patient.lastName}";
        if (fullName.toLowerCase().contains(query.toLowerCase())) {
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
      context: context,
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
                  .addPatient(addPatientEmail, widget.user.patients)
                  .then((RehappUser patient) {
                    const snackBar = SnackBar(
                      content: Text("Adding patient succeeded"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    setState(() {
                      patients.add(patient as Patient);
                      displayedPatients.add(patient);
                      widget.user.patients.add(patient.id);
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
      }
    );
  }

  String addPatientEmail = "";

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
            padding: const EdgeInsets.all(10.0),
            child: Column(children: <Widget>[
              SizedBox(
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Hi ${widget.user.firstName}",
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          const Text(
                            'Here are your patients:',
                            style: TextStyle(fontSize: 20)
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          IconButton(
                            iconSize: 30,
                            splashRadius: 25,
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
                        borderRadius:
                            BorderRadius.all(Radius.circular(25.0))),
                  )),
              ),
              Expanded(
                child: RefreshIndicator(
                  displacement: 0.0,
                  onRefresh: () async {
                    await apiService.getPatients(widget.user.patients)
                      .then((value) {
                        setState(() {
                          patients.clear();
                          displayedPatients.clear();
                          patients.addAll(value);
                          displayedPatients.addAll(value);
                        });
                      })
                      .catchError((error) {
                        const snackBar = SnackBar(
                          content: Text("Retrieving patients failed"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                  },
                  child: widget.user.patients.isEmpty ? Container(
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
                              key: Key(displayedPatients.elementAt(index).email),
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
                                apiService.deletePatient(widget.user.patients.elementAt(index))
                                  .then((value) {
                                    setState(() {
                                      displayedPatients.removeAt(index);
                                      patients.removeAt(index);
                                      widget.user.patients.removeAt(index);
                                    });
                                  }).catchError((error) {
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
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text("No"),
                                      );
                                      Widget yesButton = TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text("Yes"),
                                      );
                                      return AlertDialog(
                                        title: const Text("Delete patient?"),
                                        content: const Text("Do you want to remove this patient from your roster?"),
                                        actions: [noButton, yesButton],
                                      );
                                    });
                              },
                              direction: DismissDirection.endToStart,
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: InkWell(
                                  splashColor: Colors.blue.withAlpha(30),
                                  onTap: () => widget.onPush(displayedPatients.elementAt(index)),
                                  child: ListTile(
                                    title: Text("${displayedPatients.elementAt(index).firstName} ${displayedPatients.elementAt(index).lastName}"),
                                    subtitle: Text(displayedPatients.elementAt(index).email),
                                    leading: const SizedBox(
                                      height: double.infinity,
                                      child: Icon(
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
    );
  }
}
