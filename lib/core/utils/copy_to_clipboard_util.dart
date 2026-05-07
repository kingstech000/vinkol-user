// lib/core/utils/clipboard_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

void copyToClipboard(BuildContext context, String textToCopy,
    {String? successMessage}) {
  Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
    AppStatusDialogs.showSuccess(context, 'Copied',
        successMessage ?? 'Copied "$textToCopy" to clipboard');
  }).catchError((error) {
    AppStatusDialogs.showError(context, 'Error', 'Failed to copy: $error');
  });
}
