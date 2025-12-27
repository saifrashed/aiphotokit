import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ImageService {
  Future<void> storeImage(String image) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<String> imageList = prefs.getStringList('image_urls') ?? [];

      imageList.add(image);

      await prefs.setStringList('image_urls', imageList);
    } catch (error) {
      debugPrint('Error storing image URL: $error');
    }
  }

  Future<List<String>> getImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Reverse the list of image URLs
      return (prefs.getStringList('image_urls') ?? []).reversed.toList();
    } catch (error) {
      debugPrint('Error retrieving image URLs: $error');
      return [];
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> imageList = prefs.getStringList('image_urls') ?? [];

      imageList.remove(imageUrl);

      await prefs.setStringList('image_urls', imageList);
    } catch (error) {
      debugPrint('Error deleting image URL: $error');
    }
  }

  Future<String?> generate(String prompt) async {
    try {
      final purchaserInfo = await Purchases.getCustomerInfo();
      final userId = purchaserInfo.originalAppUserId;

      // Standard POST request
      final uri = Uri.parse(
        'https://image-production-68ec.up.railway.app/api/image/create',
      );

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": prompt}),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String? imageUrl = jsonResponse['url'];

        if (imageUrl == null) {
          throw Exception('URL not found in response');
        }

        await storeImage(imageUrl);

        // Credit deduction logic
        final creditUrl = Uri.parse(
          'https://sdasavfju5wbczf37helj63kaa0xjndb.lambda-url.us-east-1.on.aws/',
        );
        final creditBody = {
          "apiKey": "sk_DqzGEzBcnEmQlbhqEwbcrPYBDHvOX",
          "projectId": "proj980b9d92",
          "customerId": userId,
          "adjustments": {"CRD": -1},
        };

        await http.post(
          creditUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(creditBody),
        );

        return imageUrl;
      } else {
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      return null;
    }
  }

  Future<String?> edit(File file, String prompt) async {
    try {
      final purchaserInfo = await Purchases.getCustomerInfo();
      final userId = purchaserInfo.originalAppUserId;

      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://image-production-68ec.up.railway.app/api/image/edit',
        ),
      );

      // Add form fields
      request.fields['prompt'] = prompt;

      if (await file.exists()) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType('image', "png"),
        );

        request.files.add(multipartFile);
      } else {
        throw Exception('File not found: ${file.path}');
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String? imageUrl = jsonResponse['url'];

        if (imageUrl == null) {
          throw Exception('URL not found in response');
        }

        await storeImage(imageUrl);

        final url = Uri.parse(
          'https://sdasavfju5wbczf37helj63kaa0xjndb.lambda-url.us-east-1.on.aws/',
        );
        final body = {
          "apiKey": "sk_DqzGEzBcnEmQlbhqEwbcrPYBDHvOX",
          "projectId": "proj980b9d92",
          "customerId": userId,
          "adjustments": {"CRD": -1},
        };

        await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        return imageUrl;
      } else {
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      return null;
    }
  }
}
