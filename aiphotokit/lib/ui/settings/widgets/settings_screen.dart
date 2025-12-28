import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aiphotokit/ui/core/fonts.dart';
import 'package:aiphotokit/ui/core/snackbar.dart';
import 'package:aiphotokit/ui/settings/view_models/settings_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.viewModel});

  final SettingsViewmodel viewModel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsViewmodel get viewModel => widget.viewModel;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showSnackBar(context, 'Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticFeedback.heavyImpact();
            context.go("/");
          },
        ),
        forceMaterialTransparency: true,
        title: Text('Settings', style: FontStyles.titleMediumLight),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Terms of Service', style: FontStyles.bodyMediumLight),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              HapticFeedback.mediumImpact();
              _launchURL('https://saifrashed.com/terms-and-privacy.pdf');
            },
          ),
          ListTile(
            title: Text('Privacy Policy', style: FontStyles.bodyMediumLight),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              HapticFeedback.mediumImpact();
              _launchURL('https://saifrashed.com/terms-and-privacy.pdf');
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Center(
              child: Text(
                'AIPhotoKit 1.0.0',
                style: GoogleFonts.faustina(
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
