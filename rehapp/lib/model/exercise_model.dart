class Exercise {
  String patientEmail;
  String therapistEmail;
  int exerciseID;
  String exerciseName;
  String exerciseDescription;
  String? exercisePicture;
  String? exerciseVideo;
  String exerciseDuration;
  String exerciseFrequency;
  String exerciseStatus;
  String reportedDuration;
  String reportedDifficulty;
  String patientComment;

  Exercise(
      {this.patientEmail = "",
      this.therapistEmail = "",
      this.exerciseID = -1,
      this.exerciseName = "",
      this.exerciseDescription = "",
      this.exercisePicture,
      this.exerciseVideo,
      this.exerciseDuration = "",
      this.exerciseFrequency = "",
      this.exerciseStatus = "ASSIGNED",
      this.reportedDuration = "",
      this.reportedDifficulty = "",
      this.patientComment = ""});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      patientEmail: json["Patient"] ?? "",
      therapistEmail: json["Therapist"] ?? "",
      exerciseID: json["ID"] ?? "",
      exerciseName: json["ExerciseName"] ?? "",
      exerciseDescription: json["ExerciseDescription"] ?? "",
      exercisePicture: json["ExercisePicture"],
      exerciseVideo: json["ExerciseVideo"],
      exerciseDuration: json["ExerciseDuration"] ?? "",
      exerciseFrequency: json["ExerciseFrequency"] ?? "",
      exerciseStatus: json["ExerciseStatus"] ?? "",
      reportedDuration: json["ReportedDuration"] ?? "",
      reportedDifficulty: json["ReportedDifficulty"] ?? "",
      patientComment: json["PatientComment"] ?? "",
    );
  }
}
