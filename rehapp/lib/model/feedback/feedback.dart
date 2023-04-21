class PatientFeedback {
  final String id;
  final String assignmentId;
  final String date;
  final int difficulty;
  final int duration;
  final int rating;
  final String comments;

  PatientFeedback({
    this.id = "",
    this.assignmentId = "",
    this.date = "",
    this.difficulty = 0,
    this.duration = 0,
    this.rating = 0,
    this.comments = "",
  });

  factory PatientFeedback.fromJson(Map<String, dynamic> json) {
    return PatientFeedback(
      id: json["id"],
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
      "id": id,
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