import 'package:flutter/material.dart';
import 'package:aiphotokit/data/image_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required ImageService imageService})
    : _imageService = imageService {
    getBalance();
    getImages();
  }

  final ImageService _imageService;
  ImageService get imageService => _imageService;

  int? _balance;
  int? get balance => _balance;

  List<String> _images = [];
  List<String> get images => _images;

  Future<void> getImages() async {
    try {
      _images = await _imageService.getImages();
      notifyListeners();

      debugPrint(_images.toString());
    } catch (error) {
      debugPrint("Could not fetch images");
    }
  }

  Future<void> getBalance() async {
    try {
      await Purchases.invalidateVirtualCurrenciesCache();
      final virtualCurrencies = await Purchases.getVirtualCurrencies();
      final virtualCurrency = virtualCurrencies.all["CRD"];
      _balance = virtualCurrency?.balance;
      notifyListeners();
    } catch (error) {
      debugPrint("Could not fetch balance");
    }
  }
}
