import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehapp/model/add_patient_model.dart';
import 'package:rehapp/model/assign_exercise_model.dart';
import 'package:rehapp/model/delete_exercise_model.dart';
import 'package:rehapp/model/delete_patient_model.dart';
import 'package:rehapp/model/exercise_bank_model.dart';
import 'package:rehapp/model/exercise_feedback_model.dart';
import 'package:rehapp/model/get_exercise_model.dart';
import 'dart:convert';

import 'package:rehapp/model/login_model.dart';
import 'package:rehapp/model/signup_model.dart';
import 'package:rehapp/model/verify_model.dart';
import 'package:rehapp/model/get_patient_model.dart';

class APIService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore db = FirebaseFirestore.instance;
  
  Future<UserCredential> login(LoginRequestModel requestModel) async {
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: requestModel.email.toLowerCase().trim(),
        password: requestModel.password.trim()
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
      throw e;
    }
  }

  Future<UserCredential> signup(SignupRequestModel requestModel) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: requestModel.email.toLowerCase().trim(),
        password: requestModel.password.trim()
      );
      
      db.collection("users")
        .doc(userCredential.user?.uid)
        .set(requestModel.toJson())
        .onError((e, _) => print("User already exists: $e"));

      // await userCredential.user?.sendEmailVerification();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      throw e;
    }
  }

  Future<Map<String, dynamic>> getCurrentUserData() async {
    Map<String, dynamic> curUser = {};
    await db.collection('users')
      .doc(auth.currentUser?.uid)
      .get()
      .then((DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        curUser = {
          'firstName': data['firstName'],
          'lastName': data['lastName'],
          'email': data['email'],
          'role': data['role']
        };
        if (curUser["role"] == "therapist") {
          curUser["patients"] = data["patients"];
        } else {
          curUser["assignments"] = data["assignments"];
        }
      });
      return curUser;
  }

  Future<Map<String, dynamic>> getUserData(String id) async {
    Map<String, dynamic> user = {};
    await db.collection('users')
      .doc(id)
      .get()
      .then((DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        user = {
          'firstName': data['firstName'],
          'lastName': data['lastName'],
          'email': data['email'],
          'role': data['role']
        };
        if (user["role"] == "therapist") {
          user["patients"] = data["patients"];
        } else {
          user["assignments"] = data["assignments"];
        }
      });
      return user;
  }

  Future<List<dynamic>> getPatients(
      List<dynamic> patientIds) async {
    List<dynamic> patients = List.filled(patientIds.length, {
      'id': "",
      'firstName': "",
      'lastName': "",
      'email': "",
      'assignments': List.filled(0, ""),
      'role': "patient"
    });
    for(var i = 0 ; i < patientIds.length; i++ ) {
      await db.collection("users")
        .doc(patientIds[i])
        .get()
        .then((DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          patients[i] = {
            'id': patientIds[i],
            'firstName': data['firstName'],
            'lastName': data['lastName'],
            'email': data['email'],
            'assignments': data['assignments'],
            'role': data['role']
          };
        })
        .onError((e, _) => throw Exception("User with inputted email was not found: $e"));
    }
    return patients;
  }

  Future<Map<String, dynamic>> addPatient(
      String patientEmail,
      List<dynamic> patients) async {
    Map<String, dynamic> patient = {};
    await db.collection('users')
      .where('email', isEqualTo: patientEmail.toLowerCase().trim())
      .get()
      .then((QuerySnapshot query) async {
        if (query.size == 0 ) {
          throw Exception("Data was not found");
        }
        final doc = query.docs.elementAt(0);
        final data = doc.data() as Map<String, dynamic>;
        if (data["role"] != "patient") {
          throw Exception('User with email ' + patientEmail.toLowerCase().trim() + ' is not a patient');
        } else if (patients.contains(doc.id)) {
          throw Exception('Patient with email ' + patientEmail.toLowerCase().trim() + ' is already added');
        }
        db.collection('users')
          .doc(auth.currentUser?.uid)
          .update({"patients": FieldValue.arrayUnion([doc.id])});
        patient = {
          'id': doc.id,
          'firstName': data['firstName'],
          'lastName': data['lastName'],
          'email': data['email'],
          'assignments': data['assignments'],
          'role': data['role']
        };
      });
      return patient;
  }

  Future<void> deletePatient(
      String patientId) async {
    await db.collection('users')
      .doc(auth.currentUser?.uid)
      .update({"patients": FieldValue.arrayRemove([patientId])})
      .onError((e, _) => throw Exception("Patient could not be deleted: $e"));
  }

  Future<List<dynamic>> getAssignments(
     String patientId, String? therapistId) async {
    List<dynamic> assignments = [];
    if (therapistId == null) {
      await db.collection("assignments")
        .where("patientId", isEqualTo: patientId)
        .get()
        .then((QuerySnapshot query) {
          List<DocumentSnapshot> docs = query.docs;
          for (DocumentSnapshot doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            assignments.add({
              'id': doc.id,
              'exerciseId': data['exerciseId'],
              'exerciseName': data['exerciseName'],
              'patientId': data['patientId'],
              'therapistId': data['therapistId'],
              'frequency': data['frequency'],
              'duration': data['duration'],
              'completed': data['completed']
            });
          }
        })
        .onError((e, _) => throw Exception("Assignment with inputted email was not found: $e"));
    } else {
      await db.collection("assignments")
        .where("patientId", isEqualTo: patientId)
        .where("therapistId", isEqualTo: therapistId)
        .get()
        .then((QuerySnapshot query) {
          List<DocumentSnapshot> docs = query.docs;
          for (DocumentSnapshot doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            assignments.add({
              'id': doc.id,
              'exerciseId': data['exerciseId'],
              'exerciseName': data['exerciseName'],
              'patientId': data['patientId'],
              'therapistId': data['therapistId'],
              'frequency': data['frequency'],
              'duration': data['duration'],
              'completed': data['completed']
            });
          }
        })
        .onError((e, _) => throw Exception("Assignment with inputted email was not found: $e"));
    }
    print(assignments);
    return assignments;
  }

  // Future<Map<String, dynamic>> createAssignment(
  //     String patientId,
      
  //   ) async {
  //   Map<String, dynamic> patient = {};
  //   await db.collection('users')
  //     .where('email', isEqualTo: patientEmail.toLowerCase().trim())
  //     .get()
  //     .then((QuerySnapshot query) async {
  //       if (query.size == 0 ) {
  //         throw Exception("Data was not found");
  //       }
  //       final doc = query.docs.elementAt(0);
  //       final data = doc.data() as Map<String, dynamic>;
  //       if (data["role"] != "patient") {
  //         throw Exception('User with email ' + patientEmail.toLowerCase().trim() + ' is not a patient');
  //       } else if (patients.contains(doc.id)) {
  //         throw Exception('Patient with email ' + patientEmail.toLowerCase().trim() + ' is already added');
  //       }
  //       db.collection('users')
  //         .doc(auth.currentUser?.uid)
  //         .update({"patients": FieldValue.arrayUnion([doc.id])});
  //       patient = {
  //         'id': doc.id,
  //         'firstName': data['firstName'],
  //         'lastName': data['lastName'],
  //         'email': data['email'],
  //         'assignments': data['assignments'],
  //         'role': data['role']
  //       };
  //     });
  //     return patient;
  // }

  Future<void> deleteAssignment(
      String patientId,
      String assignmentId) async {
    await db.collection('users')
      .doc(patientId)
      .update({"assignments": FieldValue.arrayRemove([assignmentId])})
      .then((value) async {
        await db.collection('assignments')
          .doc(assignmentId)
          .delete()
          .onError((e, _) => throw Exception("Assignment could not be deleted: $e"));
      })
      .onError((e, _) => throw Exception("Assignment could not be deleted from patient's assignments: $e"));
  }

// ALL OLD API SERVICES BELOW:
// TODO: Refactor all below API services to utilize Firebase
  Future<GetExerciseResponseModel> getExercises(String patientEmail) async {
    String url =
        "https://rehapp.azurewebsites.net/therapist/getPatientAssignments?PatientEmail=${patientEmail}";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
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
      },
      body: jsonEncode(requestModel),
    );
    if (response.statusCode == 200) {
      return ExerciseFeedbackResponseModel.fromJson(json.decode(response.body));
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
      },
    );
    if (response.statusCode == 200) {
      return ExerciseBankResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }
}
