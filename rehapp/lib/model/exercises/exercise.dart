class Exercise {
  final String id;
  final String description;
  final String name;
  final String video;

  // fields are different and does not have status field

  Exercise({
    this.id = "",
    this.name = "",
    this.description = "",
    this.video = "",
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      video: json["video"],
    );
  }
}