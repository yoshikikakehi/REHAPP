import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/model/assignments/assignment_request.dart';
import 'package:rehapp/model/exercises/exercise.dart';
import 'package:rehapp/model/users/patient.dart';

class AssignExercisePage extends StatefulWidget {
  final Patient patient;
  const AssignExercisePage({Key? key, required this.patient}) : super(key: key);

  @override
  AssignExercisePageState createState() {
    return AssignExercisePageState();
  }
}

class AssignExercisePageState extends State<AssignExercisePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Exercise? selectedExercise;
  TextEditingController descriptionController = TextEditingController(text: "Description of the selected exercise");
  final List<Exercise> exercises = [];

  APIService apiService = APIService();
  bool isApiCallProcess = false;

  AssignmentRequest requestModel = AssignmentRequest(
    therapistId: FirebaseAuth.instance.currentUser!.uid
  );

  Map<String, bool> days = {
    "Sunday": false,
    "Monday": false,
    "Tuesday": false,
    "Wednesday": false,
    "Thursday": false,
    "Friday": false,
    "Saturday": false,
  };
  bool daysError = false;

  @override
  void initState() {
    apiService.getExercises()
      .then((exerciseValues) {
        setState(() {
          exercises.addAll(exerciseValues);
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
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Text('Assign Exercise to ${widget.patient.firstName}'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: const Text('Exercise', style: TextStyle(fontSize: 16)),
              ),
              FormField<String>(
                validator: (input) => (input == null || input.isEmpty) ? "Please select an exercise" : null,
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Select Exercise',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(5.0)
                      ),
                      errorText: state.errorText
                    ),
                    isEmpty: selectedExercise == null,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Exercise>(
                        value: selectedExercise,
                        isDense: true,
                        onChanged: (Exercise? newValue) {
                          setState(() {
                            selectedExercise = newValue;
                            descriptionController.text = selectedExercise?.description ?? "Description of the selected exercise";
                            state.didChange(newValue?.id);
                          });
                        },
                        items: exercises.map((Exercise exercise) {
                          return DropdownMenuItem<Exercise>(
                            value: exercise,
                            child: Text(exercise.name),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                onSaved: (_) {
                  requestModel.exerciseId = selectedExercise!.id;
                  requestModel.exerciseName = selectedExercise!.name;
                  requestModel.description = selectedExercise!.description;
                },
              ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: const Text('Exercise Description', style: TextStyle(fontSize: 16)),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[200],),
                child: TextField(
                  controller: descriptionController,
                  minLines: 3,
                  maxLines: null,
                  readOnly: true,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 115, 115, 115),
                    fontSize: 16
                  ),
                  decoration: InputDecoration(
                    hintText: 'Additional details about the exercise (number of sets/reps to perform, equipment to use, where to perform the exercise)',
                    hintMaxLines: 3,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0)
                    ),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: const Text('Additional Details', style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                minLines: 3,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Additional details about the exercise (number of sets/reps to perform, equipment to use, where to perform the exercise)',
                  hintMaxLines: 3,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
                onSaved: (input) => requestModel.details = input!,
              ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: const Text('Expected Time to Complete', style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                validator: (input) => input!.isEmpty ? EMPTY_RESPONSE : null,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  hintText: 'Minutes expected to complete exercise',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 32.0),
                    borderRadius: BorderRadius.circular(5.0)
                  ),
                ),
                onSaved: (input) => requestModel.duration = int.parse(input!),
              ),

              Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: const Text('Frequency', style: TextStyle(fontSize: 16)),
              ),
              Column(
                children: daysOfWeek()
              ),
              (daysError) ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  EMPTY_RESPONSE,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 221, 98, 98)
                  )
                )
              ) : Container(),

              const SizedBox(height: 20.0),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: const StadiumBorder(),
                ),
                onPressed: () async {
                  setState(() {
                    isApiCallProcess = true;
                  });
                  if (validateAndSave()) {
                    requestModel.patientId = widget.patient.id;
                    apiService.createAssignment(requestModel)
                      .then((value) {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        Navigator.pop(context, value);
                      }).catchError((error) {
                        const snackBar = SnackBar(
                          content: Text("Assigning exercises failed"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {
                          isApiCallProcess = false;
                        });
                      });
                  } else {
                    setState(() {
                      isApiCallProcess = false;
                    });
                  }
                },
                child: const Text(
                  'Assign Exercise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  List<Widget> daysOfWeek() {
    List<Widget> daysOfWeek = <Widget> [];
    days.forEach((key, value) {
      daysOfWeek.add(
        CheckboxListTile(
          value: value,
          title: Text(key),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (value) {
            setState(() {
              days[key] = value!;
            });
          }
        )
      );
    });
    return daysOfWeek;
  } 

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate() && days.values.contains(true)) {
      setState(() => daysError = false);
      form.save();
      List<String> frequency = [];
      days.forEach((key, value) {
        if (value) frequency.add(key);
      });
      requestModel.frequency = frequency;
      return true;
    } else if (!days.values.contains(true)) {
      setState(() => daysError = true);
    }
    return false;
  }
}
