import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/assets/constants.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/model/assignments/assignment_request.dart';
import 'package:rehapp/model/exercises/exercise.dart';

class EditAssignmentPage extends StatefulWidget {
  final Assignment assignment;
  final Exercise exercise;
  const EditAssignmentPage({Key? key, required this.assignment, required this.exercise}) : super(key: key);

  @override
  EditAssignmentPageState createState() {
    return EditAssignmentPageState();
  }
}

class EditAssignmentPageState extends State<EditAssignmentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController descriptionController = TextEditingController(text: "Description of the selected exercise");
  final Map<String, Exercise> exercises = {};

  APIService apiService = APIService();
  bool isApiCallProcess = false;

  AssignmentRequest requestModel = AssignmentRequest();

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
    descriptionController.text = widget.exercise.description;
    for (var element in widget.assignment.frequency) {
      days[element] = true;
    }
    requestModel = widget.assignment.toAssignmentRequest();
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
        title: const Text('Edit Assigned Exercise'),
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
              InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Select Exercise',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(5.0)
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Exercise>(
                    value: widget.exercise,
                    isDense: true,
                    onChanged: null,
                    items: [ DropdownMenuItem<Exercise>(
                      value: widget.exercise,
                      child: Text(widget.exercise.name),
                    )],
                  ),
                ),
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
                initialValue: requestModel.details,
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
                initialValue: requestModel.duration.toString(),
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
                    apiService.updateAssignment(widget.assignment.id, requestModel)
                      .then((_) {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        Navigator.pop(
                          context,
                          Assignment.fromJson(
                            {"id": widget.assignment.id}
                              ..addAll(requestModel.toJson())
                          )
                        );
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
                  'Save',
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
