class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  // final List<String> assignments;
  // final List<String> patients;

  User({
    this.id = "",
    this.email = "",
    this.firstName = "",
    this.lastName = "",
    this.role = "",
    // this.assignments = List.filled(0, ""),
    // this.patients = List.filled(0, "")
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json["id"] ?? "",
        email: json["email"] ?? "",
        firstName: json["firstName"] ?? "",
        lastName: json["lastName"] ?? "",
        role: json["role"] ?? "patient",
        // assignments: json["assignments"] ?? List.filled(0, ""),
        // patients: json["patients"] ?? List.filled(0, "")
      );
  }
}
