class StyleModel {
  String title;
  String prompt;
  String imageUrl;

  StyleModel({
    required this.title,
    required this.prompt,
    required this.imageUrl,
  });

  factory StyleModel.fromJson(Map<String, dynamic> json) {
    return StyleModel(
      title: json['title'],
      prompt: json['prompt'],
      imageUrl: json['image_url'],
    );
  }
}
