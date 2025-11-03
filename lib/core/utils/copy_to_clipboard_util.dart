// lib/core/utils/clipboard_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard functionality

/// Copies the given text to the clipboard and shows a SnackBar confirmation.
void copyToClipboard(BuildContext context, String textToCopy,
    {String? successMessage}) {
  Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(successMessage ?? 'Copied "$textToCopy" to clipboard'),
        duration:
            const Duration(seconds: 2), // How long the SnackBar is visible
      ),
    );
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to copy: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  });
}
