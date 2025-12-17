import 'dart:convert';
import 'dart:io';

import 'package:aiphotokit/data/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:aiphotokit/data/image_service.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ComposeViewmodel extends ChangeNotifier {
  ComposeViewmodel({
    required ImageService imageService,
    required this.selectedImage,
  }) : _imageService = imageService {
    fetchThemes();

    debugPrint(selectedImage.name);
  }

  XFile selectedImage;

  final ImageService _imageService;
  ImageService get imageService => _imageService;

  // New state
  List<ThemeModel> _themes = [];
  bool _isLoadingThemes = false;
  String? _themesError;

  List<ThemeModel> get themes => _themes;
  bool get isLoadingThemes => _isLoadingThemes;
  String? get themesError => _themesError;

  Future<void> generate(File file) async {
    try {
      String? url = await imageService.generate(file, "userPrompt");
      debugPrint("Generated URL: $url");
    } catch (error) {
      debugPrint("Error generating: $error");
    }
  }

  Future<void> fetchThemes() async {
    _isLoadingThemes = true;
    _themesError = null;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/data.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> themesJson = data['themes'] as List<dynamic>;
      _themes =
          themesJson
              .map((t) => ThemeModel.fromJson(t as Map<String, dynamic>))
              .toList();
    } catch (error) {
      _themesError = "Failed to load themes";
      debugPrint("fetchThemes error: $error");
    } finally {
      _isLoadingThemes = false;
      notifyListeners();
    }
  }
}
