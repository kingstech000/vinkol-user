import 'package:flutter/material.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black, // Background color of the bottom bar
      shape:
          const CircularNotchedRectangle(), // Optional: for a floating action button
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(PhosphorIconsRegular.fileText, 0, 'Documents'),
          _buildNavItem(PhosphorIconsRegular.clockCounterClockwise, 1, 'History'),
          _buildNavItem(PhosphorIconsRegular.wallet, 2, 'Wallet'),
          _buildNavItem(PhosphorIconsRegular.chatsCircle, 3, 'Chat'),
          _buildNavItem(PhosphorIconsRegular.user, 4, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selectedIndex == index ? AppColors.primary : Colors.white,
              size: 24,
            ),
            // Optional: You can add text labels below icons if needed, but not in the image
            // Text(
            //   label,
            //   style: TextStyle(
            //     color: selectedIndex == index ? AppColors.primary : Colors.white,
            //     fontSize: 10,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
