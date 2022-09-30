import 'package:flutter/material.dart';
import 'package:rehapp/model/exercise_model.dart';
import 'package:rehapp/pages/exercise_feedback.dart';
import 'package:flutter/material.dart';
import 'package:rehapp/pages/logout.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/chosen_exercise_bank.dart' as chosenExercise;

class ExerciseBankDetailPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseBankDetailPage({Key? key, required this.exercise})
      : super(key: key);

  @override
  State<ExerciseBankDetailPage> createState() => _ExerciseBankDetailPageState();
}

class _ExerciseBankDetailPageState extends State<ExerciseBankDetailPage> {
  int selectedPage = 1;
  final _pageOptions = [
    ExerciseBankDetailPage(
      exercise: Exercise(),
    ),
    ExerciseBankDetailPage(
      exercise: Exercise(),
    ),
    LogoutPage(),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: 0,
                  child: FittedBox(
                    child: widget.exercise.exercisePicture != null &&
                            widget.exercise.exercisePicture!.isNotEmpty
                        ? FadeInImage.assetNetwork(
                            imageErrorBuilder: (context, error, stackTrace) =>
                                Image.asset("lib/assets/images/default.png"),
                            fadeInDuration: const Duration(seconds: 1),
                            placeholder: "lib/assets/images/default.png",
                            image: widget.exercise.exercisePicture.toString(),
                            height: 300,
                          )
                        : Image.asset("lib/assets/images/default.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox.expand(
                  child: SafeArea(
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.75,
                      minChildSize: 0.70,
                      maxChildSize: 0.95,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            color: Colors.blue[100],
                          ),
                          child: ListView(
                            controller: scrollController,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: Wrap(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Exercise Name
                                          Text(widget.exercise.exerciseName,
                                              style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold)),
                                          // Exercise Duration
                                          if (widget.exercise.exerciseDuration
                                                  .contains("min") ||
                                              widget.exercise.exerciseDuration
                                                  .contains("Min"))
                                            Text(
                                                "Exercise Duration: ${widget.exercise.exerciseDuration}",
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                          if (!widget.exercise.exerciseDuration
                                                  .contains("min") &&
                                              !widget.exercise.exerciseDuration
                                                  .contains("Min"))
                                            Text(
                                                "Exercise Duration: ${widget.exercise.exerciseDuration} min",
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                        ],
                                      )
                                    ],
                                  )),

                              // Exercise Description
                              Text(widget.exercise.exerciseDescription,
                                  style: const TextStyle(fontSize: 18)),
                              if (widget.exercise.exerciseVideo != null &&
                                  widget.exercise.exerciseVideo!.isNotEmpty)
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _launchUrl(widget.exercise.exerciseVideo),
                                  icon: const Icon(Icons.play_circle_outlined),
                                  label: const Text("Video"),
                                ),
                              const SizedBox(height: 10.0),
                              // Complete Exercise Button
                              ElevatedButton(
                                child: const Text("Assign this exercise",
                                    style: TextStyle(fontSize: 18)),
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blue),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: const BorderSide(
                                                color: Colors.blue)))),
                                onPressed: () {
                                  chosenExercise.chosenExercise =
                                      widget.exercise;
                                  chosenExercise.hasChosenExercise = true;
                                  int count = 0;
                                  Navigator.popUntil(context, (route) {
                                    return count++ == 2;
                                  });
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : LogoutPage(),
    );
  }

  void _launchUrl(url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }
}
