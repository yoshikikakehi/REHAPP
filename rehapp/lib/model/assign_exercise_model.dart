class AssignExerciseResponseModel {
  final String status;

  AssignExerciseResponseModel({this.status = ""});

  factory AssignExerciseResponseModel.fromJson(Map<String, dynamic> json) {
    return AssignExerciseResponseModel(
      status: json["status"] ?? "",
    );
  }
}

class AssignExerciseRequestModel {
  String patientEmail;
  int? exerciseID;
  String exerciseName;
  String exerciseDescription;
  String? exercisePicture;
  String? exerciseVideo;
  String expectedDuration;
  String exerciseFrequency;

  AssignExerciseRequestModel(
      {this.patientEmail = "",
      this.exerciseID,
      this.exerciseName = "",
      this.exerciseDescription = "",
      this.exercisePicture,
      this.exerciseVideo,
      this.expectedDuration = "",
      this.exerciseFrequency = ""});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PatientEmail': patientEmail.trim(),
      'ExerciseID': exerciseID,
      'ExerciseName': exerciseName.trim(),
      'ExerciseDescription': exerciseDescription.trim(),
      'ExercisePicture':
          exercisePicture == null ? null : exercisePicture!.trim(),
      'ExerciseVideo': exerciseVideo == null ? null : exerciseVideo!.trim(),
      'ExpectedDuration': expectedDuration.trim(),
      'ExerciseFrequency': exerciseFrequency.trim(),
    };
    return map;
  }
}
