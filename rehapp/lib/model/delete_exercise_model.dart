class DeleteExerciseResponseModel {
  final String status;

  DeleteExerciseResponseModel({this.status = ""});

  factory DeleteExerciseResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteExerciseResponseModel(
      status: json["status"] ?? "",
    );
  }
}

class DeleteExerciseRequestModel {
  int exerciseID;

  DeleteExerciseRequestModel({required this.exerciseID});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'AssignmentID': exerciseID,
    };
    return map;
  }
}
