import 'dart:convert';
import 'dart:io';

import 'package:aiphotokit/data/style_model.dart';
import 'package:aiphotokit/data/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:aiphotokit/data/image_service.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ComposeViewmodel extends ChangeNotifier {
  ComposeViewmodel({
    required ImageService imageService,
    required this.selectedImage,
  }) : _imageService = imageService {
    getBalance();
    fetchThemes();
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

  // Balance
  int? _balance;
  int? get balance => _balance;

  // Selected style class
  StyleModel? _selectedStyle;
  StyleModel? get selectedStyle => _selectedStyle;

  set selectedStyle(StyleModel? value) {
    if (_selectedStyle == value) return;
    _selectedStyle = value;
    notifyListeners();
  }

  // Custom prompt
  String? _customPrompt;
  String? get customPrompt => _customPrompt;

  set customPrompt(String? value) {
    if (_customPrompt == value) return;
    _customPrompt = value;
    notifyListeners();
  }

  // Is Loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<void> generate(BuildContext context, File file, String prompt) async {
    try {
      isLoading = true;
      String? url = await imageService.generate(file, prompt);
      debugPrint("Generated URL: $url");
      isLoading = false;

      if (context.mounted) context.go("/");
    } catch (error) {
      debugPrint("Error generating: $error");
      isLoading = false;
    }
  }

  Future<void> getBalance() async {
    try {
      await Purchases.invalidateVirtualCurrenciesCache();
      final virtualCurrencies = await Purchases.getVirtualCurrencies();
      final virtualCurrency = virtualCurrencies.all["CRD"];
      _balance = virtualCurrency?.balance;

      debugPrint(_balance.toString());

      notifyListeners();
    } catch (error) {
      debugPrint("Could not fetch balance");
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
