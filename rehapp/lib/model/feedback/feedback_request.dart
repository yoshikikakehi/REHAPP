class PatientFeedbackRequest {
  String assignmentId;
  String date;
  int difficulty;
  int duration;
  int rating;
  String comments;

  PatientFeedbackRequest({
    this.assignmentId = "",
    this.date = "",
    this.difficulty = 3,
    this.duration = 0,
    this.rating = 3,
    this.comments = "",
  });

  factory PatientFeedbackRequest.fromJson(Map<String, dynamic> json) {
    return PatientFeedbackRequest(
      assignmentId: json["assignmentId"],
      date: json["date"],
      difficulty: json["difficulty"],
      duration: json["duration"],
      rating: json["rating"],
      comments: json["comments"],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "assignmentId": assignmentId,
      "date": date,
      "difficulty": difficulty,
      "duration": duration,
      "rating": rating,
      "comments": comments,
    };
    return map;
  }
}