import 'package:flutter/material.dart';
import 'package:aiphotokit/ui/core/fonts.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: FontStyles.bodySmallDark),
      backgroundColor: Colors.white,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.up,
      margin: EdgeInsets.only(bottom: 100, left: 10, right: 10),
    ),
  );
}
