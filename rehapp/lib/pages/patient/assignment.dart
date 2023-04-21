import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/model/exercises/exercise.dart';
import 'package:rehapp/pages/patient/complete_assignment.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AssignmentPage extends StatefulWidget {
  final Assignment assignment;
  const AssignmentPage({Key? key, required this.assignment}) : super(key: key);
  @override State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  APIService apiService = APIService();
  bool isApiCallProcess = true;
  Exercise exercise = Exercise();
  YoutubePlayerController? _controller;

  bool isDisabled() {
    return (widget.assignment.lastCompletedDate == DateFormat('yMMMEd').format(DateTime.now()));
  }

  Future<void> navigate() async {
    final updatedAssignment = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => 
        CompleteAssignmentPage(assignment: widget.assignment)
      )
    );

    if (!mounted) return;

    if (updatedAssignment != null) {
      Navigator.pop(
        context,
        updatedAssignment
      );
    }
  }

  @override
  void initState() {
    super.initState();
    apiService
      .getExercise(widget.assignment.exerciseId)
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
          widget.assignment.exerciseName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
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
                      widget.assignment.exerciseName,
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
                  widget.assignment.exerciseName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                  )
                ),
                // Exercise Duration
                Text(
                  "Estimated Exercise Duration: ${widget.assignment.duration} min",
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
                  widget.assignment.details,
                  style: const TextStyle(fontSize: 18)
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isDisabled() ? Colors.grey[400] : Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: const StadiumBorder(),
              ),
              onPressed: () => isDisabled() ? null : navigate(),
              child: const Text(
                "Complete Assignment",
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            )
          ),
        ],
      )
    );
  }
}