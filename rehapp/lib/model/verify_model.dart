class VerifyResponseModel {
  final String error;

  VerifyResponseModel({this.error = ""});

  factory VerifyResponseModel.fromJson(Map<String, dynamic> json) {
    print('you better be rurnign');
    return VerifyResponseModel(
      error: json["error"] ?? "",
    );
  }

  factory VerifyResponseModel.fromEmpty() {
    return VerifyResponseModel(
      error: "",
    );
  }
}

// class VerifyRequestModel {
//   String emailToken;

//   VerifyRequestModel({this.emailToken = ""});

//   Map<String, dynamic> toJson() {
//     Map<String, dynamic> map = {
//       'emailToken': emailToken.trim(),
//     };

//     return map;
//   }
// }
