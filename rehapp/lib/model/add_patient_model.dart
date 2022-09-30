class AddPatientResponseModel {
  final String status;

  AddPatientResponseModel({this.status = ""});

  factory AddPatientResponseModel.fromJson(Map<String, dynamic> json) {
    return AddPatientResponseModel(
      status: json["status"] ?? "",
    );
  }
}

class AddPatientRequestModel {
  String patientEmail;

  AddPatientRequestModel({this.patientEmail = ""});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PatientEmail': patientEmail.trim(),
    };
    return map;
  }
}
