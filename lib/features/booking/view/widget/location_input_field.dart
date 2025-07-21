import 'package:flutter/material.dart';
import 'package:starter_codes/widgets/gap.dart';

class LocationInputField extends StatelessWidget {
  final ValueChanged<String>? onLocationChanged; // If you want to pass value up

  const LocationInputField({super.key, this.onLocationChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          Gap.w10,
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Drop off location',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none, // No default underline
                isDense: true, // Reduces vertical space
                contentPadding: EdgeInsets.zero, // Remove internal padding
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
