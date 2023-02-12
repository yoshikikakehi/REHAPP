import 'dart:convert';
import 'package:crypto/crypto.dart';

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
  String firstname;
  String lastname;
  String email;
  String password;
  String role; // Hashing Process

  SignupRequestModel(
      {this.firstname = "",
      this.lastname = "",
      this.email = "",
      this.password = "",
      this.role = ""});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'firstname': firstname.trim(),
      'lastname': lastname.trim(),
      'role': role.trim(),
    };

    return map;
  }
}
