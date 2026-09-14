import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';

/// The search input: stores, products, banks. One shape everywhere.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontSize: 15,
            color: VinkolPalette.neutral900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 15,
              color: VinkolPalette.neutral400,
            ),
            prefixIcon: const Icon(
              PhosphorIconsRegular.magnifyingGlass,
              size: 20,
              color: VinkolPalette.neutral500,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(
                      PhosphorIconsRegular.xCircle,
                      size: 20,
                      color: VinkolPalette.neutral500,
                    ),
                    onPressed: controller.clear,
                  ),
            isDense: true,
            filled: true,
            fillColor: VinkolPalette.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: VinkolSpace.md,
              vertical: VinkolSpace.md,
            ),
            border: const OutlineInputBorder(
              borderRadius: VinkolRadius.brSm,
              borderSide: BorderSide(color: VinkolPalette.neutral200),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: VinkolRadius.brSm,
              borderSide: BorderSide(color: VinkolPalette.neutral200),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: VinkolRadius.brSm,
              borderSide: BorderSide(color: VinkolPalette.brand500, width: 1.5),
            ),
          ),
        );
      },
    );
  }
}
