import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/base_view_model.dart';
import 'package:starter_codes/core/utils/locator.dart';

class OnBoardingViewModel extends BaseViewModel {
  final localCache = locator<LocalCache>();
  final NavigationService _navigationService = NavigationService.instance;
  final Ref ref;
  OnBoardingViewModel({required this.ref});

  void markAsOnBoarded() async {
    try {
      await localCache.onBoarded();
    } catch (e) {
      print(e);
    }
  }
}

final onBoardingViewModelProvider = Provider<OnBoardingViewModel>((ref) {
  return OnBoardingViewModel(ref: ref);
});
