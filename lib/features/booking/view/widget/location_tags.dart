import 'package:flutter/material.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/widgets/gap.dart';

class LocationTags extends StatelessWidget {
  const LocationTags({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal, // Allows horizontal scrolling if many tags
      child: Row(
        children: [
          _buildAddButton(),
          Gap.w6,
          _buildLocationTag('Home', Icons.home),
          Gap.w6,
          _buildLocationTag('Office', Icons.work),
          Gap.w6,
          _buildLocationTag('Gym', Icons.fitness_center),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return OutlinedButton.icon(
      onPressed: () {
        // Handle add button press
      },
      icon: const Icon(Icons.add, color: AppColors.white),
      label: const Text(
        'Add',
        style: TextStyle(color: AppColors.white),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.grey[400]!), // Border color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners for button
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildLocationTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background color for tags
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
