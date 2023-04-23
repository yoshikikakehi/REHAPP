import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/model/exercises/exercise.dart';
import 'package:rehapp/model/users/patient.dart';
import 'package:rehapp/pages/therapist/edit_assignment.dart';
import 'package:rehapp/pages/therapist/view_feedback.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AssignmentPage extends StatefulWidget {
  final Assignment assignment;
  final Patient patient;
  final void Function(Assignment, Assignment) updateAssignment;
  const AssignmentPage({Key? key, required this.assignment, required this.patient, required this.updateAssignment}) : super(key: key);
  @override State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  APIService apiService = APIService();
  bool isApiCallProcess = true;
  Exercise exercise = Exercise();
  Assignment assignment = Assignment();
  YoutubePlayerController? _controller;

  Future<void> navigateAndUpdateAssignment() async {
    final newAssignment = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAssignmentPage(assignment: assignment, exercise: exercise)),
    );

    if (!mounted) return;
    if (newAssignment != null) {
      widget.updateAssignment(assignment, newAssignment);
      setState(() => assignment = newAssignment);
    }
  }

  @override
  void initState() {
    super.initState();

    setState(() => assignment = widget.assignment);
    apiService
      .getExercise(assignment.exerciseId)
      .then((Exercise exerciseValue) {
        setState(() {
          exercise = exerciseValue;
          _controller = YoutubePlayerController(
            initialVideoId: YoutubePlayer.convertUrlToId(exercise.video)!,
            flags: const YoutubePlayerFlags(
              mute: false,
              disableDragSeek: false,
              loop: true
            ),
          );
          isApiCallProcess = false;
        });
      })
      .catchError((e) {
        print(e);
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        shadowColor: Colors.grey,
        title: Text(
          assignment.exerciseName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: [
          (FirebaseAuth.instance.currentUser!.uid == assignment.therapistId) ? TextButton(
            onPressed: () => navigateAndUpdateAssignment(),
            child: const Text("Edit", style: TextStyle(color: Colors.white),)
          ) : Container()
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: (_controller != null) ? YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueAccent,
                topActions: <Widget>[
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      assignment.exerciseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
                onReady: () {},
                onEnded: (data) {},
              ),
              builder: (context, player) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: player
                );
              }
            ) : Container()
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  assignment.exerciseName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                  )
                ),
                // Exercise Duration
                Text(
                  "Estimated Exercise Duration: ${assignment.duration} min",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal
                  )
                ),
                const SizedBox(height: 8.0),
                // Exercise Description
                Text(
                  exercise.description,
                  style: const TextStyle(fontSize: 18)
                ),
                const SizedBox(height: 8.0),
                // Exercise Description
                Text(
                  assignment.details,
                  style: const TextStyle(fontSize: 18)
                ),
              ],
            ),
          ),
          (FirebaseAuth.instance.currentUser?.uid == assignment.therapistId) ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: const StadiumBorder(),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewFeedbackPage(patient: widget.patient, assignment: assignment))
              ),
              child: const Text(
                "View Feedback",
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            )
          ) : Container(),
        ],
      )
    );
  }
}
