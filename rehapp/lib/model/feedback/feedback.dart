class PatientFeedback {
  final String id;
  final String assignmentId;
  final String date;
  final String difficulty;
  final String duration;
  final String comments;

  PatientFeedback({
    this.id = "",
    this.assignmentId = "",
    this.date = "",
    this.difficulty = "",
    this.duration = "",
    this.comments = "",
  });

  factory PatientFeedback.fromJson(Map<String, dynamic> json) {
    return PatientFeedback(
      id: json["id"],
      assignmentId: json["assignmentId"],
      date: json["date"],
      difficulty: json["difficulty"],
      duration: json["duration"],
      comments: json["comments"],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "id": id,
      "assignmentId": assignmentId,
      "date": date,
      "difficulty": difficulty,
      "duration": duration,
      "comments": comments,
    };
    return map;
  }
}