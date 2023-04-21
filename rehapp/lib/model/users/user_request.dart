class RehappUserRequest {
  String email;
  String firstName;
  String lastName;
  String role;
  String? phoneNumber;
  String? profileImage;

  RehappUserRequest({
    this.email = "",
    this.firstName = "",
    this.lastName = "",
    this.role = "",
    this.phoneNumber = "",
    this.profileImage = "",
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "role": role,
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
