import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:aiphotokit/ui/core/fonts.dart';
import 'package:aiphotokit/ui/core/snackbar.dart';
import 'package:aiphotokit/ui/home/view_model/home_viewmodel.dart';
import 'package:aiphotokit/ui/home/widgets/preview_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeViewModel get viewModel => widget.viewModel;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> showPaywall() async {
    HapticFeedback.heavyImpact();
    final offerings = await Purchases.getOfferings();
    final offering = offerings.getOffering("credits");
    await RevenueCatUI.presentPaywall(offering: offering);
    await viewModel.getBalance();
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });

        HapticFeedback.heavyImpact();
        if (context.mounted) {
          context.go("/compose", extra: pickedFile);
        }
      }
    } catch (e) {
      if (context.mounted) showSnackBar(context, 'Please select an image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () async {
            await showPaywall();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Image.asset('assets/credit-icon.png', height: 24, width: 24),
                const SizedBox(width: 6),
                ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, _) {
                    if (viewModel.balance == null) {
                      return const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      );
                    } else {
                      return Text(
                        viewModel.balance.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 25),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          height: 75,
          child: FloatingActionButton.extended(
            onPressed: () {
              _pickImage(context);
            },
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/upload-icon.png', height: 32, width: 32),
                const SizedBox(width: 12),
                Text('Select an image', style: FontStyles.bodyMediumLight),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.images.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Start by selecting an image',
                      style: FontStyles.bodyMediumLight.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                debugPrint('Refreshing finetunes...');
                viewModel.getImages();
              },
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: viewModel.images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PreviewWidget(
                                viewModel: viewModel,
                                image: viewModel.images[index],
                              ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        viewModel.images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}






// FloatingActionButton.extended(
//         onPressed: () {
//           _goToGenerate(context);
//         },
//         label: Row(
//           children: [
//             Image.asset('assets/generate-icon.png', height: 24, width: 24),
//             const SizedBox(width: 8),
//             Text('Generate', style: FontStyles.bodyMediumLight),
//           ],
//         ),
//       )





  // Future<void> _goToGenerate(BuildContext context) async {
  //   try {
  //     if (viewModel.balance == null) {
  //       return;
  //     }

  //     if (viewModel.balance == 0) {
  //       await showPaywall();
  //       return;
  //     }

  //     context.go("/compose");
  //   } catch (e) {
  //     showSnackBar(context, "An error occurred: $e");
  //   }
  // }