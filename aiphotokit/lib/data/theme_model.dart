import 'package:aiphotokit/data/style_model.dart';

class ThemeModel {
  String title;
  String imageUrl;
  List<StyleModel> styles;

  ThemeModel({
    required this.title,
    required this.imageUrl,
    required this.styles,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    var stylesList = json['styles'] as List;
    List<StyleModel> styles =
        stylesList.map((style) => StyleModel.fromJson(style)).toList();

    return ThemeModel(
      title: json['title'],
      imageUrl: json['image_url'],
      styles: styles,
    );
  }
}
