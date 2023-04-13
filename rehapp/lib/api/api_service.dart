import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehapp/model/assignments/assignment_request.dart';

import 'package:rehapp/model/users/user.dart';
import 'package:rehapp/model/users/patient.dart';
import 'package:rehapp/model/users/therapist.dart';
import 'package:rehapp/model/exercises/exercise.dart';
import 'package:rehapp/model/assignments/assignment.dart';
import 'package:rehapp/model/feedback/feedback.dart';

class APIService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore db = FirebaseFirestore.instance;
  
  Future<UserCredential> login(String email, String password) async {
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password.trim()
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
      rethrow;
    }
  }

  Future<UserCredential> signup(String password, RehappUser user) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: user.email.toLowerCase().trim(),
        password: password.trim()
      );
      
      await db.collection("users")
        .doc(userCredential.user?.uid)
        .set(user.toJson())
        .onError((e, _) => throw Exception("User already exists: $e"));

      // await userCredential.user?.sendEmailVerification();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      rethrow;
    }
  }

  Future<RehappUser> getCurrentUser() async {
    late final RehappUser curUser;
    await db.collection('users')
      .doc(auth.currentUser?.uid)
      .get()
      .then((DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        if (data["role"] == "therapist") {
          curUser = Therapist(
            id: doc.id,
            firstName: data['firstName'],
            lastName: data['lastName'],
            email: data['email'],
            role: data['role'],
            patients: (data["patients"] as List).map((item) => item as String).toList()
          );
        } else {
          curUser = Patient(
            id: doc.id,
            firstName: data['firstName'],
            lastName: data['lastName'],
            email: data['email'],
            role: data['role'],
            assignments: data["assignments"] != null ? (data["assignments"] as List).map((item) => item as String).toList() : const []
          );
        }
      });
      return curUser;
  }

  Future<RehappUser> getUserData(String id) async {
    late final RehappUser user;
    await db.collection('users')
      .doc(id)
      .get()
      .then((DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        if (data["role"] == "therapist") {
          user = Therapist(
            id: id,
            firstName: data['firstName'],
            lastName: data['lastName'],
            email: data['email'],
            role: data['role'],
            patients: (data["patients"] as List).map((item) => item as String).toList()
          );
        } else {
          user = Patient(
            id: id,
            firstName: data['firstName'],
            lastName: data['lastName'],
            email: data['email'],
            role: data['role'],
            assignments: data["assignments"] != null ? (data["assignments"] as List).map((item) => item as String).toList() : const []
          );
        }
      });
      return user;
  }

  Future<List<Patient>> getPatients(
      List<String> patientIds) async {
    final List<Patient> patients = [];
    for(var i = 0 ; i < patientIds.length; i++) {
      await db.collection("users")
        .doc(patientIds[i])
        .get()
        .then((DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          patients.add(Patient(
            id: patientIds[i],
            firstName: data['firstName'],
            lastName: data['lastName'],
            email: data['email'],
            role: data['role'],
            assignments: data["assignments"] != null ? (data["assignments"] as List).map((item) => item as String).toList() : const []
          ));
        })
        .onError((e, _) => throw Exception("User was not found: $e"));
    }
    return patients;
  }

  Future<RehappUser> addPatient(
      String patientEmail,
      List<dynamic> patients) async {
    late final RehappUser patient;
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
          throw Exception('User with email ${patientEmail.toLowerCase().trim()} is not a patient');
        } else if (patients.contains(doc.id)) {
          throw Exception('Patient with email ${patientEmail.toLowerCase().trim()} is already added');
        }
        db.collection('users')
          .doc(auth.currentUser?.uid)
          .update({"patients": FieldValue.arrayUnion([doc.id])});
        patient = Patient(
          id: doc.id,
          firstName: data['firstName'],
          lastName: data['lastName'],
          email: data['email'],
          role: data['role'],
          assignments: data["assignments"] != null ? (data["assignments"] as List).map((item) => item as String).toList() : const []
        );
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

  Future<List<Assignment>> getAssignments(
     String patientId) async {
    final List<Assignment> assignments = [];
    await db.collection("assignments")
      .where("patientId", isEqualTo: patientId)
      .get()
      .then((QuerySnapshot query) {
        List<DocumentSnapshot> docs = query.docs;
        for (DocumentSnapshot doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          assignments.add(Assignment(
            id: doc.id,
            patientId: data['patientId'],
            therapistId: data['therapistId'],
            exerciseId: data['exerciseId'],
            exerciseName: data['exerciseName'],
            frequency: data["frequency"] != null ? (data["frequency"] as List).map((item) => item as String).toList() : const [],
            duration: data['duration'],
            details: data['details'],
          ));
        }
      })
      .onError((e, _) => throw Exception(e));
    return assignments;
  }

  Future<Assignment> createAssignment(
      AssignmentRequest assignmentData
    ) async {
    late final Assignment assignment;
    await db.collection("assignments")
        .add(assignmentData.toJson())
        .then((DocumentReference docRef) async {
          await docRef.get().then((DocumentSnapshot doc) async {
            await db.collection("users")
              .doc(assignmentData.patientId)
              .update({"assignments": FieldValue.arrayUnion([doc.id])});
            final data = doc.data() as Map<String, dynamic>;
            assignment = Assignment(
              id: doc.id,
              patientId: data['patientId'],
              therapistId: data['therapistId'],
              exerciseId: data['exerciseId'],
              exerciseName: data['exerciseName'],
              frequency: data["frequency"] != null ? (data["frequency"] as List).map((item) => item as String).toList() : const [],
              duration: data['duration'],
              details: data['details'],
            );
          });
        })
        .onError((e, _) => throw Exception("User already exists: $e"));
      return assignment;
  }

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

  Future<Exercise> getExercise(
      String exerciseId) async {
    late Exercise exercise;
    await db.collection('exercises')
      .doc(exerciseId)
      .get()
      .then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        exercise = Exercise(
          id: doc.id,
          name: data['name'],
          description: data['description'],
          video: data['video'],
        );
      })
      .onError((e, _) => throw Exception("Assignment could not be deleted from patient's assignments: $e"));
    return exercise;
  }

  Future<List<Exercise>> getExercises() async {
    List<Exercise> exercises = [];
    await db.collection('exercises')
      .get()
      .then((QuerySnapshot query) {
        List<DocumentSnapshot> docs = query.docs;
        for (DocumentSnapshot doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          exercises.add(
            Exercise(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              video: data['video'],
            )
          );
        }
      })
      .onError((e, _) => throw Exception(e));
    return exercises;
  }

  Future<PatientFeedback> createFeedback(
      PatientFeedback feedbackData) async {
    late final PatientFeedback feedback;
    await db.collection("feedback")
        .add(feedbackData.toJson())
        .then((DocumentReference docRef) {
          docRef.get().then((DocumentSnapshot doc) {
            final data = doc.data() as Map<String, dynamic>;
            feedback = PatientFeedback(
              id: doc.id,
              assignmentId: data["assignmentId"],
              date: data["date"],
              difficulty: data["difficulty"],
              duration: data["duration"],
              comments: data["comments"],
            );
          });
        })
        .onError((e, _) => throw Exception("User already exists: $e"));
    return feedback;
  }
}
