class Assignment {
  final String id;
  final String patientId;
  final String therapistId;
  final String exerciseId;
  final String exerciseName;
  final int duration;
  final List<String> frequency;
  final String details;
  final bool assigned;
  final int completions;
  final String lastCompletedDate;

  Assignment({
    this.id = "",
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

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json["id"],
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
      "id": id,
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