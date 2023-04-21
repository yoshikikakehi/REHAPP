import 'package:rehapp/model/users/user.dart';

class Therapist extends RehappUser {
  final List<String> patients;

  Therapist({
    super.id = "",
    super.email = "",
    super.firstName = "",
    super.lastName = "",
    super.role = "therapist",
    super.phoneNumber = "",
    super.profileImage = "",
    this.patients = const []
  });
  
  factory Therapist.fromJson(Map<String, dynamic> json) {
    return Therapist(
      id: json["id"],
      email: json["email"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      role: json["role"] ?? "therapist",
      phoneNumber: json["phoneNumber"],
      profileImage: json["profileImage"],
      patients: (json["patients"] != null) ? (json["patients"] as List).map((item) => item as String).toList() : const [],
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

    if (phoneNumber != null) {
      map["phoneNumber"] = phoneNumber;
    }
    if (profileImage != null) {
      map["profileImage"] = profileImage;
    }
    return map;
  }
}