import 'package:flutter/material.dart';

/// The editable fields for one package on the package-info form.
class ItemDetails {
  final TextEditingController packageNameController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController recipientPhoneController =
      TextEditingController();
  final TextEditingController noteController = TextEditingController();

  void dispose() {
    packageNameController.dispose();
    recipientNameController.dispose();
    recipientPhoneController.dispose();
    noteController.dispose();
  }
}
