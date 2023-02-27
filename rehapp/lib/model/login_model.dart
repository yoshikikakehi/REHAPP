import 'package:rehapp/model/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class LoginResponseModel {
  final String token;
  final bool success;
  final String status;
  final int expiresIn;
  final String error;
  final User user;

  // should create additional checks to confirm all fields are valid
  LoginResponseModel(
      {this.token = "",
      this.success = false,
      this.status = "",
      this.expiresIn = -1,
      this.error = "",
      required this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
        token: json["token"] ?? "",
        success: json["success"],
        status: json["status"],
        expiresIn: json["expiresIn"] ?? -1,
        error: json["error"] ?? "",
        user: User.fromJson(json["user"]));
  }
}

class LoginRequestModel {
  String email;
  String password;

  LoginRequestModel({this.email = "", this.password = ""});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'email': email.trim(),
      'password': sha256.convert(utf8.encode(password)).toString(),
    };

    return map;
  }
}
