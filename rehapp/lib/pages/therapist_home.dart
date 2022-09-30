import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/main.dart';
import 'package:rehapp/model/add_patient_model.dart';
import 'package:rehapp/model/delete_patient_model.dart';
import 'package:rehapp/model/user_model.dart';
import 'package:rehapp/pages/exercise.dart';
import 'package:rehapp/pages/logout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/user.dart' as user;

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

  int selectedPage = 1;
  final _pageOptions = [
    TherapistHomePage(),
    TherapistHomePage(),
    LogoutPage(),
  ];

  List<User> names = [];
  List<User> items = [];

  @override
  void initState() {
    APIService apiService = APIService();
    apiService.getPatients().then((value) {
      if (mounted) {
        setState(() {
          names.addAll(value.patients);
          items.addAll(names);
        });
      }
      isApiCallProcess = false;
    }).catchError((error) {
      const snackBar = SnackBar(
        content: Text("Loading patients failed"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      isApiCallProcess = false;
    });
    super.initState();
  }

  void filterSearchResults(String query) {
    // Implementation for Search Bar
    List<User> nameSearchList = [];
    nameSearchList.addAll(names);
    print(nameSearchList);
    if (query.isNotEmpty) {
      List<User> nameData = [];
      for (var user in nameSearchList) {
        String fullName = user.firstname + " " + user.lastname;
        if (fullName.contains(query)) {
          nameData.add(user);
          print(nameData);
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
        items.addAll(names);
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
                  APIService apiService = APIService();
                  apiService
                      .addPatient(
                          AddPatientRequestModel(patientEmail: addPatientEmail))
                      .then((value) {
                    const snackBar = SnackBar(
                      content: Text("Adding patient succeeded"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    setState(() {
                      Navigator.pop(context);
                      _textFieldController.clear();
                    });
                  }).catchError((error) {
                    const snackBar = SnackBar(
                      content: Text("A patient with that email does not exist"),
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
      body: selectedPage != 2
          ? Stack(
              children: <Widget>[
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: <Widget>[
                      Container(
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Hi " + user.firstname,
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
                                    onPressed: () =>
                                        {_displayTextInputDialog(context)},
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
                          onRefresh: () async {
                            APIService apiService = APIService();
                            await apiService.getPatients().then((value) {
                              setState(() {
                                names.clear();
                                items.clear();
                                names.addAll(value.patients);
                                items.addAll(names);
                              });
                              isApiCallProcess = false;
                            }).catchError((error) {
                              const snackBar = SnackBar(
                                content: Text("Retrieving patients failed"),
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
                                      key: Key(items[index].email),
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
                                            .deletePatient(
                                                DeletePatientRequestModel(
                                                    patientEmail:
                                                        items[index].email))
                                            .then((value) {
                                          setState(() {
                                            items.removeAt(index);
                                            names.removeAt(index);
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
                                                    builder: (context) =>
                                                        ExercisePage(
                                                          user: items[index],
                                                        )));
                                          },
                                          child: ListTile(
                                            title: Text(items[index].firstname +
                                                " " +
                                                items[index].lastname),
                                            subtitle: Text(items[index]
                                                .email), //will have to fix this later since subtitles list will shift while searching
                                            leading: const Icon(
                                                Icons.account_circle_outlined,
                                                color: Colors.black),
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
