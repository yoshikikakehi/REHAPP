class DeletePatientResponseModel {
  final String status;

  DeletePatientResponseModel({this.status = ""});

  factory DeletePatientResponseModel.fromJson(Map<String, dynamic> json) {
    return DeletePatientResponseModel(
      status: json["status"] ?? "",
    );
  }
}

class DeletePatientRequestModel {
  String patientEmail;

  DeletePatientRequestModel({this.patientEmail = ""});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PatientEmail': patientEmail.trim(),
    };
    return map;
  }
}
