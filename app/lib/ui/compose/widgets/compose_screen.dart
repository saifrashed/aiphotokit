import 'dart:io';

import 'package:aiphotokit/ui/compose/widgets/selection_screen.dart';
import 'package:aiphotokit/ui/core/fonts.dart';
import 'package:aiphotokit/ui/core/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:aiphotokit/ui/compose/view_model/compose_viewmodel.dart';
import 'package:aiphotokit/data/theme_model.dart';
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

  ThemeModel? selectedTheme;

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
        final bool showStyleOption = !hasCustomPrompt;

        // 1. Wrap Scaffold in PopScope to prevent system back navigation
        return PopScope(
          canPop: !viewModel.isLoading,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                // 2. Disable the UI back button if loading
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
                      // Optional: Disable style selection while loading too
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
                                : 'Add a style',
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.55,
                                ),
                                child: Image.file(
                                  File(viewModel.selectedImage.path),
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (viewModel.selectedStyle == null ||
                                hasCustomPrompt)
                              TextField(
                                controller: _promptController,
                                // Optional: Disable text input while loading
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
                                      'Choose a style or describe your desired style in this textbox...',
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
                                  '- Generated by AI so results may not always be accurate.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- The recommendation is to upload a high-quality selfie with one face. Follow style theme cover image as an example.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- The face should be clearly visible for the AI.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- If a generation did not go through then the AI system blocked it for safety reasons, try again if you think it was not correct.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- Images containing profanity will be blocked by the system.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- Users retain commercial rights to generated images.',
                                  style: FontStyles.bodyMediumLight.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '- Uploaded images are processed solely for creation and not stored.',
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
                          // 3. Disable clicks by setting onPressed to null if loading
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
                                        "Please enter a prompt or select a style",
                                      );
                                      return;
                                    }

                                    if (viewModel.balance == 0) {
                                      showPaywall();
                                      return;
                                    }

                                    debugPrint(
                                      "Generating with prompt: $prompt",
                                    );

                                    viewModel.generate(
                                      context,
                                      File(viewModel.selectedImage.path),
                                      prompt,
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          // 4. Show Spinner if loading, else show Text/Icon
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
                                      const SizedBox(
                                        width: 12,
                                      ), // Space between spinner and text
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
                                        style: FontStyles.bodyMediumLight
                                            .copyWith(fontSize: 18),
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
