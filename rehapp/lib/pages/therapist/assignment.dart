import 'dart:math';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/model/exercises/exercise.dart';
import '../../ProgressHUD.dart';

class AssignmentPage extends StatefulWidget {
  final Assignment assignment;

  const AssignmentPage({Key? key, required this.assignment}) : super(key: key);

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  APIService apiService = APIService();
  bool isApiCallProcess = true;
  Exercise exercise = Exercise();
  YoutubePlayerController? _controller;

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
    _controller!.dispose();
    super.dispose();
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
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
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
                onEnded: (data) {
                  _controller!.reset();
                },
              ),
              builder: (context, player) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: player
                );
              }
            ) : Container()
          ),
          SizedBox.expand(
            child: DraggableScrollableSheet(
              initialChildSize: max((MediaQuery.of(context).size.height - 56 - 58 - min(MediaQuery.of(context).size.width, 800) / 2) / (MediaQuery.of(context).size.height - 56 - 58), 0.3),
              minChildSize: max((MediaQuery.of(context).size.height - 56 - 58 - min(MediaQuery.of(context).size.width, 800) * 9 / 16) / (MediaQuery.of(context).size.height - 56 - 58), 0.2),
              maxChildSize: 1,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    color: Colors.blue[100],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    controller: scrollController,
                    children: [
                      // Exercise Name
                      Text(widget.assignment.exerciseName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      // Exercise Duration
                      Text(
                        "Exercise Duration: ${widget.assignment.duration} min",
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
                      const SizedBox(height: 10.0),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      )
    );
  }
}
