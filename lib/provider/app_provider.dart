import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/app/data/app_service.dart';
import 'package:starter_codes/features/app/model/app_details_model.dart';

final appDetailsProvider = FutureProvider<AppDetailsResponse>((ref) async {
  final appService = ref.read(appServiceProvider);
  return await appService.getAppDetails();
});

