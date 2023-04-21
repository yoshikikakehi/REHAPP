import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/model/feedback/feedback_request.dart';

class CompleteAssignmentPage extends StatefulWidget {
  final Assignment assignment;
  const CompleteAssignmentPage({Key? key, required this.assignment}) : super(key: key);
  @override State<CompleteAssignmentPage> createState() => _CompleteAssignmentPageState();
}

class _CompleteAssignmentPageState extends State<CompleteAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  bool isApiCallProcess = false;
  PatientFeedbackRequest requestModel = PatientFeedbackRequest();

  @override
  void initState() {
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
      appBar: AppBar(
        title: Text('Complete ${widget.assignment.exerciseName}'),
      ),
      body: Builder(builder: (context) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: const Text('Time Taken to Complete', style: TextStyle(fontSize: 16)),
                ),
                TextFormField(
                  validator: (input) => input!.isEmpty ? EMPTY_RESPONSE : null,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    hintText: 'Minutes spent on exercise',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 32.0),
                      borderRadius: BorderRadius.circular(5.0)
                    ),
                  ),
                  onSaved: (input) => requestModel.duration = int.parse(input!),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(children: const <Widget>[
                    Text('Difficulty', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 5),
                    Text(
                      'Rate the difficulty of this exercise\n(1: Very Easy, 5: Very Difficult)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12)
                    ),
                  ])
                ),
                Slider(
                  value: requestModel.difficulty.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: requestModel.difficulty.round().toString(),
                  onChanged: (double value) => {
                    setState(() => requestModel.difficulty = value.toInt())
                  },
                ),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(children: const <Widget>[
                    Text('Rating', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 5),
                    Text(
                      'Rate this exercise based on enjoyment\n(1: Not enjoyable, 5: Very enjoyable)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12)
                    ),
                  ])
                ),
                Slider(
                  value: requestModel.rating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: requestModel.rating.round().toString(),
                  onChanged: (double value) => {
                    setState(() => requestModel.rating = value.toInt())
                  },
                ),

                Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: const Text('Comments', style: TextStyle(fontSize: 16)),
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  minLines: 4,
                  maxLines: null, //allows the textbox to resize dynamically
                  decoration: InputDecoration(
                    hintText: 'Optional comments about the exercise (how many sets/reps you completed, how long you rested in between sets, whether you enjoyed the exercise, etc.)',
                    hintMaxLines: 3,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 32.0),
                      borderRadius: BorderRadius.circular(5.0)
                    ),
                  ),
                  onSaved: (input) => requestModel.comments = input!,
                ),

                const SizedBox(height: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    setState(() => isApiCallProcess = true);
                    if (validateAndSave()) {
                      APIService apiService = APIService();
                      requestModel.assignmentId = widget.assignment.id;
                      requestModel.date = DateFormat('yMMMEd').format(DateTime.now());
                      apiService.createFeedback(requestModel)
                        .then((value) {
                          setState(() => isApiCallProcess = false);
                          Map<String, dynamic> json = widget.assignment.toJson();
                          json["lastCompletedDate"] = requestModel.date;
                          Navigator.pop(
                            context,
                            Assignment.fromJson(json)
                          );
                        })
                        .catchError((error) {
                          setState(() => isApiCallProcess = false);
                          const snackBar = SnackBar(
                            content: Text("Feedback could not be created"),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                    } else {
                      setState(() =>isApiCallProcess = false);
                    }
                  },
                  child: const Text(
                    'Submit Feedback',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ]),
            )
          )
        );
      }),
    );
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
