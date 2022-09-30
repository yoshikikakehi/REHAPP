import 'package:flutter/material.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/exercise_model.dart';
import 'package:rehapp/pages/completed_exercises.dart';
import 'package:rehapp/pages/exercise_detail.dart';
import 'package:rehapp/pages/logout.dart';
//import 'package:rehapp/assets/constants.dart';
// import 'package:flutter_svg/flutter_svg.dart';

import '../ProgressHUD.dart';
import '../api/user.dart' as user;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController editingController = TextEditingController();
  final ScrollController _controller = ScrollController();
  // GlobalKey<ScaffoldState> _scaffoldKey =
  //     GlobalKey<ScaffoldState>(); // used for the hamburger menu
  final TextEditingController _textFieldController = TextEditingController();
  bool isApiCallProcess = true;

  List<Exercise> exercises = [];
  List<Exercise> completedExercises = [];

  int selectedPage = 1;
  final _pageOptions = [
    HomePage(),
    HomePage(),
    LogoutPage(),
  ];

  @override
  void initState() {
    APIService apiService = APIService();
    apiService.getMyExercises().then((value) {
      setState(() {
        for (Exercise e in value.exercises) {
          if (e.exerciseStatus == "ASSIGNED") {
            exercises.add(e);
          } else {
            completedExercises.add(e);
          }
        }
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

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
    );
  }

  Widget _uiSetup(BuildContext context) {
    ScrollController _controller = ScrollController();
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
                      SizedBox(
                        height: 85,
                        child: Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text('Welcome, ${user.firstname}',
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    const Text('Exercises to do',
                                        style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 5),
                                    OutlinedButton(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CompletedExercisePage(
                                                    completedExercises:
                                                        completedExercises,
                                                  ))),
                                      child: const Text("Completed Exercises"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: exercises.isEmpty
                            ? const Text(
                                "Looks like you have no exercises assigned.")
                            : RefreshIndicator(
                                onRefresh: () async {
                                  APIService apiService = APIService();
                                  await apiService
                                      .getMyExercises()
                                      .then((value) {
                                    setState(() {
                                      exercises.clear();
                                      completedExercises.clear();
                                      for (Exercise e in value.exercises) {
                                        if (e.exerciseStatus == "ASSIGNED") {
                                          exercises.add(e);
                                        } else {
                                          completedExercises.add(e);
                                        }
                                      }
                                      isApiCallProcess = false;
                                    });
                                  }).catchError((error) {
                                    const snackBar = SnackBar(
                                      content: Text("Loading exercises failed"),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    setState(() {
                                      isApiCallProcess = false;
                                    });
                                  });
                                },
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics()),
                                    controller: _controller,
                                    itemCount: exercises.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0))),
                                        elevation: 3,
                                        child: InkWell(
                                            splashColor:
                                                Colors.blue.withAlpha(30),
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ExerciseDetailPage(
                                                    exercise: exercises[index],
                                                  ),
                                                )),
                                            child: Column(
                                              children: <Widget>[
                                                exercises[index].exercisePicture !=
                                                            null &&
                                                        exercises[index]
                                                            .exercisePicture!
                                                            .isNotEmpty
                                                    ? FadeInImage.assetNetwork(
                                                        imageErrorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Image.asset(
                                                                "lib/assets/images/default.png"),
                                                        fadeInDuration:
                                                            const Duration(
                                                                seconds: 1),
                                                        placeholder:
                                                            "lib/assets/images/default.png",
                                                        image: exercises[index]
                                                            .exercisePicture
                                                            .toString(),
                                                        height: 100,
                                                      )
                                                    : Image.asset(
                                                        "lib/assets/images/default.png"),
                                                ListTile(
                                                  title: Text(exercises[index]
                                                      .exerciseName),
                                                  subtitle: Text(
                                                      exercises[index]
                                                          .exerciseFrequency),
                                                ),
                                              ],
                                            )),
                                      );
                                    }),
                              ),
                      )
                    ]),
                  ),
                ),
              ],
            )
          : LogoutPage(),
    );
  }
}
