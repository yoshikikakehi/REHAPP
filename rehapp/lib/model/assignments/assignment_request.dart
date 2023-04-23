class AssignmentRequest {
  String patientId;
  String therapistId;
  String exerciseId;
  String exerciseName;
  int duration;
  List<String> frequency;
  String details;
  bool assigned;
  int completions;
  String lastCompletedDate;

  AssignmentRequest({
    this.patientId = "",
    this.therapistId = "",
    this.exerciseId = "",
    this.exerciseName = "",
    this.duration = 0,
    this.frequency = const [],
    this.details = "",
    this.assigned = true,
    this.completions = 0,
    this.lastCompletedDate = "",
  });

  factory AssignmentRequest.fromJson(Map<String, dynamic> json) {
    return AssignmentRequest(
      patientId: json["patientId"],
      therapistId: json["therapistId"],
      exerciseId: json["exerciseId"],
      exerciseName: json["exerciseName"],
      duration: json["duration"],
      frequency: json["frequency"] != null ? (json["frequency"] as List).map((item) => item as String).toList() : const [],
      details: json["details"],
      assigned: json["assigned"],
      completions: json["completions"],
      lastCompletedDate: json["lastCompletedDate"],
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
      "assigned": assigned,
      "completions": completions,
      "lastCompletedDate": lastCompletedDate,
    };
    return map;
  }
}