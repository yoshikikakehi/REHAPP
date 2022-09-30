class ExerciseFeedbackResponseModel {
  final String status;

  ExerciseFeedbackResponseModel({this.status = ""});

  factory ExerciseFeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseFeedbackResponseModel(
      status: json["status"] ?? "",
    );
  }
}

class ExerciseFeedbackRequestModel {
  int exerciseID;
  String actualDuration;
  String actualDifficulty;
  String? comment;

  ExerciseFeedbackRequestModel(
      {required this.exerciseID,
      this.actualDuration = "",
      this.actualDifficulty = "",
      this.comment});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'AssignmentID': exerciseID,
      'CompletionTime': actualDuration.trim(),
      'DifficultyLevel': actualDifficulty.trim(),
      'Comment': comment == null ? null : comment!.trim(),
    };
    return map;
  }
}
