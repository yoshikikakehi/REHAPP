import 'package:flutter/material.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/users/patient.dart';
import 'package:rehapp/model/users/therapist.dart';


class StatisticsPage extends StatefulWidget {
  final Therapist user;
  const StatisticsPage({Key? key, required this.user}) : super(key: key);
  @override State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool isApiCallProcess = true;
  APIService apiService = APIService();

  Map<String, dynamic> statistics = {};
  List<Patient> patients = [];
  Patient? selectedPatient;

  @override
  void initState() {
    super.initState();

    apiService
      .getStatistics(widget.user.id, widget.user.patients)
      .then((value) => setState(() => statistics = value))
      .then((_) => apiService
        .getPatients(widget.user.patients)
        .then((value) => setState(() {
            patients.addAll(value);
            isApiCallProcess = false;
          })
        ));
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
        preferredSize: const Size.fromHeight(64),
        child: Container(
          margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            title: const Text(
              "Statistics",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              IconButton(
                splashRadius: 25,
                iconSize: 30,
                onPressed: () => {},
                icon: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.black
                )
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: (statistics.isNotEmpty) ? Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 20, left: 12, right: 12),
                child: const Text(
                  "General Therapist Statistics:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Total Assignments Assigned: ${statistics['totalAssignments']}",
                      style: const TextStyle(
                        fontSize: 16
                      )
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Current Number of Patients: ${widget.user.patients.length}",
                      style: const TextStyle(
                        fontSize: 16
                      )
                    ),
                  ]
                ),
              ),
              (selectedPatient != null) ? Container(
                padding: const EdgeInsets.only(top: 20, left: 12, right: 12),
                child: Text(
                  "Statistics for ${selectedPatient!.firstName} ${selectedPatient!.lastName}:",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ) : Container(
                padding: const EdgeInsets.only(top: 20, left: 12, right: 12),
                child: const Text(
                  "Patient Statistics:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: const Text(
                  "Select a patient below to view that patient's exercise statistics:",
                  style: TextStyle(
                    fontSize: 16
                  )
                ),
              ),
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: 'Select Patient',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0)
                    ),
                  ),
                  isEmpty: selectedPatient == null,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Patient>(
                      value: selectedPatient,
                      isDense: true,
                      onChanged: (Patient? newValue) {
                        setState(() => selectedPatient = newValue);
                      },
                      items: patients.map((Patient patient) {
                        return DropdownMenuItem<Patient>(
                          value: patient,
                          child: Text("${patient.firstName} ${patient.lastName}"),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              (selectedPatient != null) ? Column(
                children: <Widget>[
                  ...(statistics[selectedPatient!.id] as Map).entries.map((entry) {
                    return ((entry.value as Map)["timesAssigned"] > 0) ? Column(
                      children: <Widget>[
                        const SizedBox(height: 20),
                        Text(
                          "${(entry.value as Map)["exerciseName"]}: ",
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Number of times assigned: ${(entry.value as Map)["timesAssigned"]}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Number of times completed: ${(entry.value as Map)["timesCompleted"]}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Average reported difficulty: ${(entry.value as Map)["averageDifficulty"].toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Average reported duration: ${(entry.value as Map)["averageDuration"].toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Average rating: ${(entry.value as Map)["averageRating"].toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ]
                    ) : Container();
                  }),
                ]
              ) : Container()
            ]
          ) : Container(),
        ),
      )
    );
  }
}
