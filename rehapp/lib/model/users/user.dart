abstract class RehappUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  RehappUser({
    this.id = "",
    this.email = "",
    this.firstName = "",
    this.lastName = "",
    this.role = "",
  });

  Map<String, dynamic> toJson();
}
