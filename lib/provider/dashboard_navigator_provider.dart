// lib/features/dashboard/view_model/dashboard_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Defines a StateProvider that holds the currently selected index for the bottom navigation bar.
// It starts at 0, representing the first tab.
final navigationIndexProvider = StateProvider<int>((ref) => 0);