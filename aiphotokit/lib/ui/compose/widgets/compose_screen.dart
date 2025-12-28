import 'dart:io';

import 'package:aiphotokit/ui/compose/widgets/selection_screen.dart';
import 'package:aiphotokit/ui/core/fonts.dart';
import 'package:aiphotokit/ui/core/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:aiphotokit/ui/compose/view_model/compose_viewmodel.dart';
import 'package:aiphotokit/data/theme_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key, required this.viewModel});

  final ComposeViewmodel viewModel;

  @override
  ComposeScreenState createState() => ComposeScreenState();
}

class ComposeScreenState extends State<ComposeScreen> {
  ComposeViewmodel get viewModel => widget.viewModel;

  final ImagePicker _picker = ImagePicker();

  ThemeModel? selectedTheme;
  XFile? _selectedImage;

  late final TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: viewModel.customPrompt);

    viewModel.addListener(_updateControllerFromViewModel);

    _promptController.addListener(() {
      viewModel.customPrompt = _promptController.text;
    });
  }

  void _updateControllerFromViewModel() {
    final newText = viewModel.customPrompt ?? '';
    if (_promptController.text != newText) {
      _promptController.text = newText;
      _promptController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });

        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (context.mounted) showSnackBar(context, 'Please select an image');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      viewModel.selectedStyle = null;
    });
  }

  Future<void> showPaywall() async {
    HapticFeedback.heavyImpact();
    final offerings = await Purchases.getOfferings();
    final offering = offerings.getOffering("credits");
    await RevenueCatUI.presentPaywall(offering: offering);
    await viewModel.getBalance();
  }

  @override
  void dispose() {
    viewModel.removeListener(_updateControllerFromViewModel);
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final bool hasCustomPrompt =
            (viewModel.customPrompt ?? '').trim().isNotEmpty;
        final bool showStyleOption = !hasCustomPrompt && _selectedImage != null;

        return PopScope(
          canPop: !viewModel.isLoading,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed:
                    viewModel.isLoading
                        ? null
                        : () {
                          if (selectedTheme != null) {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              selectedTheme = null;
                            });
                          } else {
                            HapticFeedback.heavyImpact();
                            context.go("/");
                          }
                        },
              ),
              actions: [
                if (showStyleOption)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap:
                          viewModel.isLoading
                              ? null
                              : () {
                                HapticFeedback.heavyImpact();

                                if (viewModel.selectedStyle != null) {
                                  viewModel.selectedStyle = null;
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => SelectionScreen(
                                            viewModel: viewModel,
                                          ),
                                    ),
                                  );
                                }
                              },
                      child: Row(
                        children: [
                          Text(
                            viewModel.selectedStyle != null
                                ? viewModel.selectedStyle!.title
                                : 'Apply a style',
                            style: FontStyles.bodyMediumLight,
                          ),
                          const SizedBox(width: 4),
                          Image.asset(
                            viewModel.selectedStyle != null
                                ? 'assets/remove-icon.png'
                                : 'assets/add-icon.png',
                            height: 32,
                            width: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_selectedImage == null)
                              GestureDetector(
                                onTap: () => {_pickImage(context)},
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/upload-icon.png',
                                        height: 50,
                                        width: 50,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Upload to edit an image",
                                        style: FontStyles.bodyMediumLight
                                            .copyWith(
                                              fontSize: 14,
                                              color: Colors.white54,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (_selectedImage != null)
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_selectedImage!.path),
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: _removeImage,
                                      child: const CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.black54,
                                        child: Icon(
                                          Icons.close,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 20),
                            if (viewModel.selectedStyle == null ||
                                hasCustomPrompt)
                              TextField(
                                controller: _promptController,
                                enabled: !viewModel.isLoading,
                                maxLines: 5,
                                minLines: 3,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: FontStyles.bodyMediumLight.copyWith(
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      _selectedImage == null
                                          ? "What do you want to create?"
                                          : "What do you want to change?",
                                  hintStyle: FontStyles.bodyMediumLight
                                      .copyWith(
                                        fontSize: 14,
                                        color: Colors.white54,
                                      ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '- AI results may vary in accuracy.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- For best results, use high-quality images matching the style.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- Ensure faces are clearly visible.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- Safety filters may block generations. Retry if this seems incorrect.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- Inappropriate content will be blocked.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- You retain commercial rights to your images.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- Images are processed for creation only and not stored.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 75,
                        child: ElevatedButton(
                          onPressed:
                              viewModel.isLoading
                                  ? null
                                  : () {
                                    HapticFeedback.heavyImpact();

                                    final String prompt =
                                        (viewModel.customPrompt ?? '')
                                                .trim()
                                                .isNotEmpty
                                            ? viewModel.customPrompt!
                                            : viewModel.selectedStyle?.prompt ??
                                                '';

                                    if (prompt.isEmpty) {
                                      showSnackBar(
                                        context,
                                        "Enter a prompt or apply a style",
                                      );
                                      return;
                                    }

                                    if (viewModel.balance == 0) {
                                      showPaywall();
                                      return;
                                    }

                                    if (_selectedImage == null) {
                                      viewModel.generate(context, prompt);
                                    }

                                    if (_selectedImage != null) {
                                      viewModel.edit(
                                        context,
                                        File(_selectedImage!.path),
                                        prompt,
                                      );
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child:
                              viewModel.isLoading
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Generating...',
                                        style: FontStyles.bodyMediumLight
                                            .copyWith(fontSize: 18),
                                      ),
                                    ],
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/generate-icon.png',
                                        height: 32,
                                        width: 32,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Generate',
                                        style: FontStyles.bodyLargeLight,
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            resizeToAvoidBottomInset: true,
          ),
        );
      },
    );
  }
}
