import 'package:rehapp/model/user_model.dart';

class GetPatientResponseModel {
  final List<User> patients;

  GetPatientResponseModel({required this.patients});

  factory GetPatientResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json["patients"] as List;
    List<User> patientList = list.map((i) => User.fromJson(i)).toList();
    return GetPatientResponseModel(patients: patientList);
  }
}
