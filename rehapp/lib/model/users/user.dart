import 'package:rehapp/model/users/user_request.dart';

abstract class RehappUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? phoneNumber;
  final String? profileImage;

  RehappUser({
    this.id = "",
    this.email = "",
    this.firstName = "",
    this.lastName = "",
    this.role = "",
    this.phoneNumber = "",
    this.profileImage = "",
  });

  Map<String, dynamic> toJson();

  RehappUserRequest toRehappUserRequest() {
    return RehappUserRequest(
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
    );
  }
}
