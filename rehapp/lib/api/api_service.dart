import 'package:http/http.dart' as http;
import 'package:rehapp/model/add_patient_model.dart';
import 'package:rehapp/model/assign_exercise_model.dart';
import 'package:rehapp/model/delete_exercise_model.dart';
import 'package:rehapp/model/delete_patient_model.dart';
import 'package:rehapp/model/exercise_bank_model.dart';
import 'package:rehapp/model/exercise_feedback_model.dart';
import 'package:rehapp/model/get_exercise_model.dart';
import 'dart:convert';
import '../api/token.dart' as token;

import 'package:rehapp/model/login_model.dart';
import 'package:rehapp/model/signup_model.dart';
import 'package:rehapp/model/verify_model.dart';
import 'package:rehapp/model/get_patient_model.dart';

class APIService {
  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    String url = "https://rehapp.azurewebsites.net/authenticate/login";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestModel),
    );
    if (response.statusCode == 200) {
      print(response.body);
      return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<SignupResponseModel> signup(SignupRequestModel requestModel) async {
    String url = "https://rehapp.azurewebsites.net/authenticate/register";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestModel),
    );
    print(jsonEncode(requestModel));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isEmpty) {
        return SignupResponseModel.fromEmpty();
      }
      return SignupResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  // Not in use
  Future<VerifyResponseModel> verify(VerifyRequestModel requestModel) async {
    String url = "https://jd.pathfinderfs.com/api/auth/verify-email";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestModel),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return VerifyResponseModel.fromEmpty();
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<GetPatientResponseModel> getPatients() async {
    String url = "https://rehapp.azurewebsites.net/therapist/getPatients";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token.value}",
      },
    );
    if (response.statusCode == 200) {
      return GetPatientResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<GetExerciseResponseModel> getExercises(String patientEmail) async {
    String url =
        "https://rehapp.azurewebsites.net/therapist/getPatientAssignments?PatientEmail=${patientEmail}";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token.value}",
      },
    );
    if (response.statusCode == 200) {
      return GetExerciseResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<GetExerciseResponseModel> getMyExercises() async {
    String url =
        "https://rehapp.azurewebsites.net/patient/getAssignedExercises";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token.value}",
      },
    );
    if (response.statusCode == 200) {
      return GetExerciseResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<AssignExerciseResponseModel> assignExercises(
      AssignExerciseRequestModel requestModel) async {
    String url =
        "https://rehapp.azurewebsites.net/therapist/createPatientAssignment";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token.value}",
      },
      body: jsonEncode(requestModel),
    );
    print(jsonEncode(requestModel));
    if (response.statusCode == 200) {
      return AssignExerciseResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<DeleteExerciseResponseModel> deleteExercises(
      DeleteExerciseRequestModel requestModel) async {
    String url =
        "https://rehapp.azurewebsites.net/therapist/deletePatientAssignment";
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token.value}",
      },
      body: jsonEncode(requestModel),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return DeleteExerciseResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<ExerciseFeedbackResponseModel> sendFeedback(
      ExerciseFeedbackRequestModel requestModel) async {
    String url = "https://rehapp.azurewebsites.net/patient/createExerciseNote";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token.value}",
      },
      body: jsonEncode(requestModel),
    );
    if (response.statusCode == 200) {
      return ExerciseFeedbackResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<AddPatientResponseModel> addPatient(
      AddPatientRequestModel requestModel) async {
    String url = "https://rehapp.azurewebsites.net/therapist/addPatient";
    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token.value}",
      },
      body: jsonEncode(requestModel),
    );
    if (response.statusCode == 200) {
      return AddPatientResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<DeletePatientResponseModel> deletePatient(
      DeletePatientRequestModel requestModel) async {
    String url = "https://rehapp.azurewebsites.net/therapist/deletePatient";
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token.value}",
      },
      body: jsonEncode(requestModel),
    );
    if (response.statusCode == 200) {
      return DeletePatientResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<ExerciseBankResponseModel> getExerciseBank() async {
    String url = "https://rehapp.azurewebsites.net/ExerciseBank";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token.value}",
      },
    );
    if (response.statusCode == 200) {
      return ExerciseBankResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }
}
