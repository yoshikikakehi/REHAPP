class Assignment {
  final String id;
  final String patientId;
  final String therapistId;
  final String exerciseId;
  final String exerciseName;
  final String duration;
  final List<String> frequency;
  final String details;

  Assignment({
    this.id = "",
    this.patientId = "",
    this.therapistId = "",
    this.exerciseId = "",
    this.exerciseName = "",
    this.duration = "",
    this.frequency = const [],
    this.details = "",
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json["id"],
      patientId: json["patientId"],
      therapistId: json["therapistId"],
      exerciseId: json["exerciseId"],
      exerciseName: json["exerciseName"],
      duration: json["duration"],
      frequency: json["frequency"],
      details: json["details"],
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
    };
    return map;
  }
}