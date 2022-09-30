// ignore_for_file: non_constant_identifier_names

import 'package:rehapp/model/exercise_model.dart';

class GetExerciseResponseModel {
  final String status;
  final List<Exercise> exercises;

  GetExerciseResponseModel({this.status = "", required this.exercises});

  factory GetExerciseResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json["assignments"] as List;
    List<Exercise> exerciseList =
        list.map((i) => Exercise.fromJson(i)).toList();
    return GetExerciseResponseModel(
      status: json["status"],
      exercises: exerciseList,
    );
  }
}
