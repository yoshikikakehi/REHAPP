class User {
  final String email;
  final String firstname;
  final String lastname;
  final String role;

  User(
      {this.email = "",
      this.firstname = "",
      this.lastname = "",
      this.role = ""});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        email: json["email"] ?? "",
        firstname: json["firstname"] ?? "",
        lastname: json["lastname"] ?? "",
        role: json["role"] ?? "patient");
  }
  User fromJson(Map<String, dynamic> json) {
    return User(
        email: json["email"] ?? "",
        firstname: json["firstname"] ?? "",
        lastname: json["lastname"] ?? "",
        role: json["role"] ?? "patient");
  }


}
