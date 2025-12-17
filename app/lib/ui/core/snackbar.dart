import 'package:flutter/material.dart';
import 'package:aiphotokit/ui/core/fonts.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: FontStyles.bodyMediumDark),
      backgroundColor: Colors.white,
      duration: const Duration(seconds: 2),
    ),
  );
}
