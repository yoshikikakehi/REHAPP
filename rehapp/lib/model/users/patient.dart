import 'package:rehapp/model/users/user.dart';

class Patient extends RehappUser {
  final List<String> assignments;

  Patient({
    super.id = "",
    super.email = "",
    super.firstName = "",
    super.lastName = "",
    super.role = "",
    this.assignments = const [],
  });
  
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json["id"],
      email: json["email"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      role: json["role"],
      assignments: (json["assignments"] as List).map((item) => item as String).toList(),
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
      "assignments": assignments,
    };
    return map;
  }
}