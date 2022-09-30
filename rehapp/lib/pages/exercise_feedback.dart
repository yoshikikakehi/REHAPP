import 'package:flutter/material.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/model/exercise_feedback_model.dart';
import 'package:rehapp/model/exercise_model.dart';
import 'package:rehapp/pages/home.dart';

import '../ProgressHUD.dart';

class ExerciseFeedbackPage extends StatefulWidget {
  final Exercise exercise;
  const ExerciseFeedbackPage({Key? key, required this.exercise})
      : super(key: key);

  @override
  ExerciseFeedbackPageState createState() {
    return ExerciseFeedbackPageState();
  }
}

class ExerciseFeedbackPageState extends State<ExerciseFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  late ExerciseFeedbackRequestModel requestModel;
  bool isApiCallProcess = false;
  bool _radioError = false;
  //int _value = 1; //difficulty radio buttons value

  @override
  void initState() {
    super.initState();
    requestModel =
        ExerciseFeedbackRequestModel(exerciseID: widget.exercise.exerciseID);
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
    );
  }

  int _value = 0; //difficulty radio buttons value

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes on ${widget.exercise.exerciseName}'),
      ),
      body: Builder(builder: (context) {
        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    const Text('Time', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      validator: (input) =>
                          input!.isEmpty ? EMPTY_RESPONSE : null,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          hintText: 'Minutes Spent on Exercise',
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 32.0),
                              borderRadius: BorderRadius.circular(5.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(5.0))),
                      onSaved: (input) => requestModel.actualDuration = input!,
                    ),
                    const SizedBox(height: 10.0),
                    const Text('Difficulty Level',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10.0),
                    // TextFormField(
                    //   validator: (input) =>
                    //       input!.isEmpty ? EMPTY_RESPONSE : null,
                    //   keyboardType: TextInputType.text,
                    //   decoration: InputDecoration(
                    //       hintText: 'Easy, Medium, or Hard',
                    //       border: OutlineInputBorder(
                    //           borderSide: const BorderSide(
                    //               color: Colors.grey, width: 32.0),
                    //           borderRadius: BorderRadius.circular(5.0)),
                    //       focusedBorder: OutlineInputBorder(
                    //           borderSide: const BorderSide(
                    //               color: Colors.grey, width: 1.0),
                    //           borderRadius: BorderRadius.circular(5.0))),
                    //   onSaved: (input) =>
                    //       requestModel.actualDifficulty = input!,
                    // ),
                    Column(children: [
                      RadioListTile(
                        title: const Text("Easy"),
                        value: 1,
                        groupValue: _value,
                        onChanged: (value) {
                          setState(() {
                            _value = 1;
                          });
                        },
                      ),
                      RadioListTile(
                        title: const Text("Moderate"),
                        value: 2,
                        groupValue: _value,
                        onChanged: (value) {
                          setState(() {
                            _value = 2;
                          });
                        },
                      ),
                      RadioListTile(
                        title: const Text("Hard"),
                        value: 3,
                        groupValue: _value,
                        onChanged: (value) {
                          setState(() {
                            _value = 3;
                          });
                        },
                      ),
                      if (_radioError == true)
                        Visibility(
                          visible: _radioError,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Please select a difficulty",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).errorColor),
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 10.0),
                    const Text('Comments', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      maxLines: null, //allows the textbox to resize dynamically
                      decoration: InputDecoration(
                          hintText: 'Optional',
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 32.0),
                              borderRadius: BorderRadius.circular(5.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(5.0))),
                      onSaved: (input) => requestModel.comment = input!,
                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 50),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        shape: const StadiumBorder(),
                        primary: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isApiCallProcess = true;
                        });
                        if (validateAndSave()) {
                          APIService apiService = APIService();
                          apiService.sendFeedback(requestModel).then((value) {
                            setState(() {
                              isApiCallProcess = false;
                            });
                            int count = 0;
                            Navigator.of(context).popUntil((_) => count++ >= 2);
                          }).catchError((error) {
                            setState(() {
                              isApiCallProcess = false;
                            });
                            const snackBar = SnackBar(
                              content: Text("Sending feedback failed"),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          });
                        } else {
                          setState(() {
                            isApiCallProcess = false;
                          });
                        }
                      },
                      child: const Text(
                        'Submit notes',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ]),
                )));
      }),
    );
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate() && _value != 0) {
      form.save();

      switch (_value) {
        case 1:
          requestModel.actualDifficulty = "EASY";
          break;
        case 2:
          requestModel.actualDifficulty = "MODERATE";
          break;
        case 3:
          requestModel.actualDifficulty = "HARD";
          break;
        default:
          requestModel.actualDifficulty = "EASY";
          break;
      }
      return true;
    }
    if (_value == 0) {
      _radioError = true;
    }
    if (_value != 0) {
      _radioError = false;
    }
    return false;
  }
}
