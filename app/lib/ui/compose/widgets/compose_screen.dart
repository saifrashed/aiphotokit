import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:aiphotokit/ui/core/fonts.dart';
import 'package:aiphotokit/ui/compose/view_model/compose_viewmodel.dart';
import 'package:aiphotokit/data/theme_model.dart'; // Make sure this is imported

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key, required this.viewModel});

  final ComposeViewmodel viewModel;

  @override
  ComposeScreenState createState() => ComposeScreenState();
}

class ComposeScreenState extends State<ComposeScreen> {
  ComposeViewmodel get viewModel => widget.viewModel;

  // Currently selected theme
  ThemeModel? selectedTheme;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    print('Custom prompt tapped');
                  },
                  child: Row(
                    children: [
                      Text('Custom prompt', style: FontStyles.bodyMediumLight),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/custom-icon.png',
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedTheme != null)
                      Text(
                        selectedTheme!.title,
                        style: FontStyles.titleLargeLight,
                      ),
                    if (selectedTheme == null)
                      Text("Themes", style: FontStyles.titleLargeLight),
                    const SizedBox(height: 8),
                    Text(
                      selectedTheme != null
                          ? "Select a style"
                          : "Select a theme",
                      style: FontStyles.bodyMediumLight,
                    ),
                    const SizedBox(height: 32),

                    if (viewModel.isLoadingThemes)
                      const Center(child: CircularProgressIndicator())
                    else if (viewModel.themesError != null)
                      Center(
                        child: Text(
                          viewModel.themesError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            selectedTheme != null
                                ? selectedTheme!.styles.length
                                : viewModel.themes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.0,
                            ),
                        itemBuilder: (context, index) {
                          if (selectedTheme == null) {
                            // Showing themes
                            final theme = viewModel.themes[index];
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                setState(() {
                                  selectedTheme = theme;
                                });
                              },
                              child: buildThemeCard(
                                imageUrl: theme.imageUrl,
                                title: theme.title,
                              ),
                            );
                          } else {
                            // Showing styles
                            final style = selectedTheme!.styles[index];
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                print('Selected style: ${style.title}');
                                // Later: use style.prompt for generation
                              },
                              child: buildStyleCard(
                                imageUrl: style.imageUrl,
                                title: style.title,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildThemeCard({required String imageUrl, required String title}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.error, color: Colors.red));
            },
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
                stops: [0.0, 0.7],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStyleCard({required String imageUrl, required String title}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.error, color: Colors.red));
            },
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
                stops: [0.0, 0.6],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
