import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;

  const CustomTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Background for the tab bar itself
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 48, // Fixed height for the tab bar container
        decoration: BoxDecoration(
          color: Colors.grey[300], // Background for the unselected tab area
          borderRadius: BorderRadius.circular(
              16), // Rounded corners for the entire tab container
        ),
        child: TabBar(
          controller: tabController, dividerHeight: 0,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color:
                Colors.blue[700], // Darker blue for the selected tab indicator
            borderRadius: BorderRadius.circular(16),
          ),
          labelColor: Colors.white, // Text color for selected tab
          unselectedLabelColor: Colors.black, // Text color for unselected tabs
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Package Delivery'),
            Tab(text: 'Store Delivery'),
          ],
        ),
      ),
    );
  }
}
