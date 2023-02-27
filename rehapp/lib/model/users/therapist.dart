import 'package:rehapp/model/users/user.dart';

class Therapist extends RehappUser {
  final List<String> patients;

  Therapist({
    super.id = "",
    super.email = "",
    super.firstName = "",
    super.lastName = "",
    super.role = "patient",
    this.patients = const []
  });
  
  factory Therapist.fromJson(Map<String, dynamic> json) {
    return Therapist(
      id: json["id"],
      email: json["email"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      role: json["role"],
      patients: (json["patients"] as List).map((item) => item as String).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "id": id,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "role": role,
      "patients": patients,
    };
    return map;
  }
}