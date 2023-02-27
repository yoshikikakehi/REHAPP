//this class is for signup stuff
import 'dart:convert';
import 'package:crypto/crypto.dart';

//this model is used for signing up the user either as a patient or a therapist
class SignupResponseModel {
  final String error;

  SignupResponseModel({this.error = ""});

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    print('something wrong here?');
    return SignupResponseModel(
      error: json["error"] != null ? json["error"] : "",
    );
  }

  factory SignupResponseModel.fromEmpty() {
    return SignupResponseModel(
      error: "",
    );
  }
}

class SignupRequestModel {
  String firstName;
  String lastName;
  String email;
  String password;
  String role; // Hashing Process

  SignupRequestModel(
      {this.firstName = "",
      this.lastName = "",
      this.email = "",
      this.password = "",
      this.role = ""});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim(),
      'role': role.trim(),
      'assignments': [],
    };

    if (role == "therapist") {
      map['patients'] = [];
    }

    return map;
  }
}
