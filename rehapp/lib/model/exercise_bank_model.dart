// ignore_for_file: non_constant_identifier_names

import 'package:rehapp/model/exercise_model.dart';

class ExerciseBankResponseModel {
  final String status;
  final List<Exercise> exercises;

  ExerciseBankResponseModel({this.status = "", required this.exercises});

  factory ExerciseBankResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json["exercises"] as List;
    List<Exercise> exerciseList =
        list.map((i) => Exercise.fromJson(i)).toList();
    return ExerciseBankResponseModel(
      status: json["status"],
      exercises: exerciseList,
    );
  }
}
