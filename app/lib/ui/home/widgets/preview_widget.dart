import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aiphotokit/ui/core/fonts.dart';
import 'package:aiphotokit/ui/core/snackbar.dart';
import 'package:aiphotokit/ui/home/view_model/home_viewmodel.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class PreviewWidget extends StatefulWidget {
  const PreviewWidget({
    super.key,
    required this.viewModel,
    required this.image,
  });

  final HomeViewModel viewModel;
  final String image;

  @override
  PreviewWidgetState createState() => PreviewWidgetState();
}

class PreviewWidgetState extends State<PreviewWidget> {
  HomeViewModel get viewModel => widget.viewModel;
  String get image => widget.image;

  @override
  void initState() {
    super.initState();
  }

  void _shareImage() async {
    http.Response response = await http.get(Uri.parse(image));
    Uint8List bytes = response.bodyBytes;

    final params = ShareParams(
      title: "I Created a Stunning Hijab Look with HijabAI!",
      text:
          "Look at this amazing image I designed using HijabAI! Try it yourself and create your own unique style! ✨ #HijabAI",
      files: [XFile.fromData(bytes, mimeType: 'image/png')],
      fileNameOverrides: ['image.png'],
    );
    HapticFeedback.heavyImpact();
    await SharePlus.instance.share(params);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
          },
        ),
        title: Image.asset('assets/logo.png', height: 25),
        actions: [
          GestureDetector(
            onTap: () async {
              await viewModel.imageService.deleteImage(image);
              showSnackBar(context, "Photo has been flagged and deleted");
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [Icon(Icons.flag, size: 32, color: Colors.red)],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareImage,
        label: Row(
          children: [
            Image.asset('assets/share-icon.png', height: 24, width: 24),
            const SizedBox(width: 8),
            Text('Share', style: FontStyles.bodyMediumLight),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.network(
                image,
                width: double.infinity,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Failed to load image');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
