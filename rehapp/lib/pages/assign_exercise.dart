import 'package:flutter/material.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/model/assign_exercise_model.dart';
import 'package:rehapp/model/user_model.dart';
import 'package:rehapp/pages/exercise_bank.dart';
//import 'package:rehapp/model/contact_model.dart';

import '../api/chosen_exercise_bank.dart' as chosenExercise;
import '../ProgressHUD.dart';

class AssignExercisePage extends StatefulWidget {
  final User user;
  const AssignExercisePage({Key? key, required this.user}) : super(key: key);

  @override
  AssignExercisePageState createState() {
    return AssignExercisePageState();
  }
}

class AssignExercisePageState extends State<AssignExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name_controller = TextEditingController();
  final TextEditingController _description_controller = TextEditingController();
  final TextEditingController _duration_controller = TextEditingController();
  final TextEditingController _picture_controller = TextEditingController();
  final TextEditingController _video_controller = TextEditingController();

  late AssignExerciseRequestModel requestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    requestModel = AssignExerciseRequestModel();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
    );
  }

  bool _sunday = false;
  bool _monday = false;
  bool _tuesday = false;
  bool _wednesday = false;
  bool _thursday = false;
  bool _friday = false;
  bool _saturday = false;
  bool _checkboxError = false;

  var child;
  @override
  Widget _uiSetup(BuildContext context) {
    final appTitle = 'Assign Exercise to ${widget.user.firstname}';

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appTitle,
        home: Scaffold(
          appBar: AppBar(
            title: Text(appTitle),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    primary: Theme.of(context).colorScheme.onPrimary),
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseBankPage(),
                      ));
                  setState(() {
                    if (chosenExercise.hasChosenExercise) {
                      _name_controller.text =
                          chosenExercise.chosenExercise.exerciseName;
                      _description_controller.text =
                          chosenExercise.chosenExercise.exerciseDescription;
                      _duration_controller.text =
                          chosenExercise.chosenExercise.exerciseDuration;
                      _picture_controller.text =
                          chosenExercise.chosenExercise.exercisePicture!;
                      _video_controller.text =
                          chosenExercise.chosenExercise.exerciseVideo!;
                    }
                  });
                },
                child: const Text('Templates'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  const Text('Name', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    validator: (input) =>
                        input!.isEmpty ? EMPTY_RESPONSE : null,
                    controller: _name_controller,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        hintText: 'Exercise Name',
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 32.0),
                            borderRadius: BorderRadius.circular(5.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(5.0))),
                    onSaved: (input) => requestModel.exerciseName = input!,
                  ),
                  const SizedBox(height: 10.0),
                  const Text('Description', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    validator: (input) =>
                        input!.isEmpty ? EMPTY_RESPONSE : null,
                    keyboardType: TextInputType.text,
                    controller: _description_controller,
                    maxLines:
                        null, // allows the textbox to resize in height dynamically
                    decoration: InputDecoration(
                        hintText: 'Brief description of exercise',
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 32.0),
                            borderRadius: BorderRadius.circular(5.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(5.0))),
                    onSaved: (input) =>
                        requestModel.exerciseDescription = input!,
                  ),
                  const SizedBox(height: 10.0),
                  const Text('Time', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    validator: (input) =>
                        input!.isEmpty ? EMPTY_RESPONSE : null,
                    keyboardType: TextInputType.text,
                    controller: _duration_controller,
                    decoration: InputDecoration(
                        hintText: 'Minutes expected to complete exercise',
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 32.0),
                            borderRadius: BorderRadius.circular(5.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(5.0))),
                    onSaved: (input) => requestModel.expectedDuration = input!,
                  ),
                  const SizedBox(height: 10.0),
                  const Text('Days', style: TextStyle(fontSize: 16)),
                  Column(
                    children: [
                      CheckboxListTile(
                          value: _sunday,
                          title: const Text("Sunday"),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _sunday = value!;
                            });
                          }),
                      CheckboxListTile(
                          value: _monday,
                          title: const Text("Monday"),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _monday = value!;
                            });
                          }),
                      CheckboxListTile(
                          value: _tuesday,
                          title: const Text("Tuesday"),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _tuesday = value!;
                            });
                          }),
                      CheckboxListTile(
                          value: _wednesday,
                          title: const Text("Wednesday"),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _wednesday = value!;
                            });
                          }),
                      CheckboxListTile(
                          value: _thursday,
                          title: const Text("Thursday"),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _thursday = value!;
                            });
                          }),
                      CheckboxListTile(
                          value: _friday,
                          title: const Text("Friday"),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _friday = value!;
                            });
                          }),
                      CheckboxListTile(
                          value: _saturday,
                          title: const Text("Saturday"),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _saturday = value!;
                            });
                          }),
                      if (_checkboxError == true)
                        Visibility(
                          visible: _checkboxError,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "You need to select at least one day",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).errorColor),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  const Text('Image', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _picture_controller,
                    decoration: InputDecoration(
                        hintText: 'Link to an Example Image',
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 32.0),
                            borderRadius: BorderRadius.circular(5.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(5.0))),
                    onSaved: (input) => input!.isNotEmpty
                        ? requestModel.exercisePicture = input
                        : null,
                  ),
                  const SizedBox(height: 10.0),
                  const Text('Video', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _video_controller,
                    decoration: InputDecoration(
                        hintText: 'Link to Example Video',
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 32.0),
                            borderRadius: BorderRadius.circular(5.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(5.0))),
                    onSaved: (input) => input!.isNotEmpty
                        ? requestModel.exerciseVideo = input
                        : null,
                  ),
                  const SizedBox(height: 20.0),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 50),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: const StadiumBorder(),
                      primary: Colors.white,
                    ),
                    onPressed: () async {
                      setState(() {
                        isApiCallProcess = true;
                      });
                      if (validateAndSave()) {
                        requestModel.patientEmail = widget.user.email;
                        APIService apiService = APIService();
                        List<String> frequency =
                            requestModel.exerciseFrequency.split(';');
                        print(frequency);
                        int i = 0;
                        while (i < frequency.length - 1) {
                          requestModel.exerciseFrequency = frequency[i];
                          await apiService
                              .assignExercises(requestModel)
                              .then((value) {
                            print('in loop');
                          }).catchError((error) {
                            print(error);
                          });
                          i++;
                        }
                        setState(() {
                          isApiCallProcess = false;
                        });
                        Navigator.pop(context, requestModel);
                        // apiService.assignExercises(requestModel).then((value) {
                        //   setState(() {
                        //     isApiCallProcess = false;
                        //   });
                        //   Navigator.pop(context, requestModel);
                        // }).catchError((error) {
                        //   print(error);
                        //   const snackBar = SnackBar(
                        //     content: Text("Assigning exercises failed"),
                        //   );
                        //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        //   setState(() {
                        //     isApiCallProcess = false;
                        //   });
                        //   Navigator.pop(context, requestModel);
                        // });
                      } else {
                        setState(() {
                          isApiCallProcess = false;
                        });
                      }
                    },
                    child: const Text(
                      'Assign Exercise',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ));
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate() &&
        (_sunday ||
            _monday ||
            _tuesday ||
            _wednesday ||
            _thursday ||
            _friday ||
            _saturday)) {
      setState(() {
        _checkboxError = false;
      });
      form.save();
      String days = "";
      days += _sunday ? "Sunday;" : "";
      days += _monday ? "Monday;" : "";
      days += _tuesday ? "Tuesday;" : "";
      days += _wednesday ? "Wednesday;" : "";
      days += _thursday ? "Thursday;" : "";
      days += _friday ? "Friday;" : "";
      days += _saturday ? "Saturday;" : "";
      requestModel.exerciseFrequency = days;
      return true;
    } else if (_sunday ||
        _monday ||
        _tuesday ||
        _wednesday ||
        _thursday ||
        _friday ||
        _saturday) {
      setState(() {
        _checkboxError = false;
      });
    } else {
      setState(() {
        _checkboxError = true;
      });
    }
    return false;
  }
}
