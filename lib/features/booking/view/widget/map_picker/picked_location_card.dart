import 'package:flutter/material.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The card at the foot of the location picker: what the pin currently
/// resolves to, and the button that accepts it.
class PickedLocationCard extends StatelessWidget {
  final String? address;
  final bool isLoadingAddress;
  final bool showingStateError;
  final VoidCallback onConfirm;

  const PickedLocationCard({
    super.key,
    required this.address,
    required this.isLoadingAddress,
    required this.showingStateError,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: showingStateError ? Colors.red : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.bookingSelectedLocation,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Gap.h12,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: isLoadingAddress
                ? Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.l10n.bookingGettingAddress,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  )
                : Text(
                    address ?? 'Move map to pick location...',
                    style: TextStyle(
                      color:
                          showingStateError ? Colors.red[700] : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
          ),
          Gap.h16,
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              title: context.l10n.bookingConfirmThisLocation,
              onTap: (isLoadingAddress || address == null || showingStateError)
                  ? null
                  : onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}
