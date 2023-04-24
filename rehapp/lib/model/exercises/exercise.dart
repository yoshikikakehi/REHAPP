class Exercise {
  final String id;
  final String description;
  final String name;
  final String video;

  // fields are different and does not have status field

  Exercise({
    this.id = "",
    this.description = "",
    this.name = "",
    this.video = "",
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json["id"],
      description: json["description"],
      name: json["name"],
      video: json["video"],
    );
  }
}