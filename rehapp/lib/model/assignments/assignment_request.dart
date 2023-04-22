class AssignmentRequest {
  String patientId;
  String therapistId;
  String exerciseId;
  String exerciseName;
  int duration;
  List<String> frequency;
  String details;
  String description;

  AssignmentRequest({
    this.patientId = "",
    this.therapistId = "",
    this.exerciseId = "",
    this.exerciseName = "",
    this.duration = 0,
    this.frequency = const [],
    this.details = "",
    this.description = "", //ADDED
  });

  factory AssignmentRequest.fromJson(Map<String, dynamic> json) {
    return AssignmentRequest(
      patientId: json["patientId"],
      therapistId: json["therapistId"],
      exerciseId: json["exerciseId"],
      exerciseName: json["exerciseName"],
      duration: json["duration"],
      frequency: json["frequence"] != null ? (json["frequence"] as List).map((item) => item as String).toList() : const [],
      details: json["details"],
      description: json["description"], // ADDED
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "patientId": patientId,
      "therapistId": therapistId,
      "exerciseId": exerciseId,
      "exerciseName": exerciseName,
      "duration": duration,
      "frequency": frequency,
      "details": details,
      "description": description, // ADDED
    };
    return map;
  }
}