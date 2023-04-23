import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/model/feedback/feedback.dart';
import 'package:rehapp/model/users/patient.dart';


class ViewFeedbackPage extends StatefulWidget {
  final Patient patient;
  final Assignment assignment;
  const ViewFeedbackPage({Key? key, required this.patient, required this.assignment}) : super(key: key);
  @override State<ViewFeedbackPage> createState() => _ViewFeedbackPageState();
}

class _ViewFeedbackPageState extends State<ViewFeedbackPage> {
  TextEditingController editingController = TextEditingController();
  final ScrollController _controller = ScrollController();
  bool isApiCallProcess = true;
  APIService apiService = APIService();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<PatientFeedback> feedback = [];

  @override
  void initState() {
    apiService
      .getFeedback(widget.assignment.id)
      .then((value) {
        setState(() {
          feedback.addAll(value.reversed);
          isApiCallProcess = false;
        });
      }).catchError((error) {
        const snackBar = SnackBar(
          content: Text("Failed loading feedback for this assignment"),
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
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          backgroundColor: Colors.blue[300],
          shadowColor: Colors.grey,
          title: Text(
            "${widget.patient.firstName}'s Feedback\nfor ${widget.assignment.exerciseName}",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: RefreshIndicator(
              displacement: 0.0,
              onRefresh: () async {
                apiService.getFeedback(widget.assignment.id).then((value) {
                  setState(() {
                    feedback.clear();
                    feedback.addAll(value.reversed);
                  });
                }).catchError((error) {
                  const snackBar = SnackBar(
                    content: Text("Loading feedback for assignment failed"),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                });
              },
              child: feedback.isEmpty ? Container(
                alignment: Alignment.center,
                child: Text(
                  "Patient has yet to complete the assignment",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16.0
                  )
                ),
              ) : ListView.builder(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                controller: _controller,
                itemCount: feedback.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Padding(
                      padding: (index == 0) ? const EdgeInsets.only(top: 20, left: 15.0, right: 15.0,) : const EdgeInsets.symmetric(horizontal: 15.0,),
                      child: Card(
                        key: Key(feedback.elementAt(index).id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  feedback.elementAt(index).date,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  "Reported Duration: ${feedback.elementAt(index).duration.toString()} min\n"
                                  "Reported Difficulty: ${feedback.elementAt(index).difficulty.toString()}\n"
                                  "Rating: ${feedback.elementAt(index).rating.toString()}\n"
                                  "Comments: ${feedback.elementAt(index).comments}",
                                  textAlign: TextAlign.left,
                                    style: const TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          )
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
        ]
      )
    );
  }
}