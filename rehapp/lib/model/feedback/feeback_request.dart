class PatientFeedbackRequest {
  String assignmentId;
  String date;
  String difficulty;
  String duration;
  String comments;

  PatientFeedbackRequest({
    this.assignmentId = "",
    this.date = "",
    this.difficulty = "",
    this.duration = "",
    this.comments = "",
  });

  factory PatientFeedbackRequest.fromJson(Map<String, dynamic> json) {
    return PatientFeedbackRequest(
      assignmentId: json["assignmentId"],
      date: json["date"],
      difficulty: json["difficulty"],
      duration: json["duration"],
      comments: json["comments"],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "assignmentId": assignmentId,
      "date": date,
      "difficulty": difficulty,
      "duration": duration,
      "comments": comments,
    };
    return map;
  }
}