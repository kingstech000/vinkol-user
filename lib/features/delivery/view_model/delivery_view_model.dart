import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/base_view_model.dart';
import 'package:starter_codes/core/services/dialog_service.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/features/delivery/data/delivery_service.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/models/app_state/view_model_state.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/models/exception.dart';

class FailureModel with Failure {
  @override
  final String message;
  @override
  final String title;

  FailureModel({required this.message, this.title = "Error"});
}

enum OrderTabType {
  packageDelivery,
  storeDelivery,
}

class DeliveryViewModel extends BaseViewModel {
  final DeliveryService _deliveryService;
  final DialogService _dialogService;
  final AppLogger _logger;

  DeliveryViewModel(this._deliveryService, this._dialogService, this._logger);

  List<DeliveryModel> _packageDeliveries = [];
  List<DeliveryModel> _storeDeliveries = [];

  bool _isLoadingPackageDeliveries = false;
  bool _isLoadingStoreDeliveries = false;
  // bool _isLoadingDownloadReport = false; // Now handled by BaseViewModel state

  String? _packageDeliveryError;
  String? _storeDeliveryError;

  // --- New: Stale Time Logic ---
  DateTime? _lastFetchedPackageDeliveries;
  DateTime? _lastFetchedStoreDeliveries;
  final Duration staleTime = const Duration(minutes: 5); // Data considered stale after 5 minutes

  List<DeliveryModel> get packageDeliveries => _packageDeliveries;
  List<DeliveryModel> get storeDeliveries => _storeDeliveries;

  bool get isLoadingPackageDeliveries => _isLoadingPackageDeliveries;
  bool get isLoadingStoreDeliveries => _isLoadingStoreDeliveries;
  // bool get isLoadingDownloadReport => _isLoadingDownloadReport; // Now handled by BaseViewModel isBusy

  String? get packageDeliveryError => _packageDeliveryError;
  String? get storeDeliveryError => _storeDeliveryError;

  /// Helper to check if data is stale
  bool _isDataStale(DateTime? lastFetched) {
    if (lastFetched == null) return true;
    return DateTime.now().difference(lastFetched) > staleTime;
  }

  /// Fetches package deliveries.
  /// Set [forceRefresh] to true to bypass stale time check.
  Future<void> fetchPackageDeliveries({bool forceRefresh = false}) async {
    if (_isLoadingPackageDeliveries && !forceRefresh) return; // Prevent re-fetching if already loading unless forced

    // Only fetch if data is stale or forceRefresh is true
    if (!forceRefresh && !_isDataStale(_lastFetchedPackageDeliveries) && _packageDeliveries.isNotEmpty) {
      _logger.i('Package deliveries data is not stale. Using cached data.');
      return;
    }

    _isLoadingPackageDeliveries = true;
    _packageDeliveryError = null;
    notifyListeners();

    try {
      final data = await _deliveryService.getOrders(orderType: 'Delivery');
      _packageDeliveries = data;
      _lastFetchedPackageDeliveries = DateTime.now(); // Update last fetched time
      _logger.i('Successfully fetched package deliveries.');
    } catch (e) {
      _packageDeliveryError = 'Failed to load package deliveries: ${e.toString()}';
      _logger.e(_packageDeliveryError);
    } finally {
      _isLoadingPackageDeliveries = false;
      notifyListeners();
    }
  }

  /// Fetches store deliveries.
  /// Set [forceRefresh] to true to bypass stale time check.
  Future<void> fetchStoreDeliveries({bool forceRefresh = false}) async {
    if (_isLoadingStoreDeliveries && !forceRefresh) return; // Prevent re-fetching if already loading unless forced

    // Only fetch if data is stale or forceRefresh is true
    if (!forceRefresh && !_isDataStale(_lastFetchedStoreDeliveries) && _storeDeliveries.isNotEmpty) {
      _logger.i('Store deliveries data is not stale. Using cached data.');
      return;
    }

    _isLoadingStoreDeliveries = true;
    _storeDeliveryError = null;
    notifyListeners();

    try {
      final data = await _deliveryService.getOrders(orderType: 'Shopping');
      _storeDeliveries = data;
      _lastFetchedStoreDeliveries = DateTime.now(); // Update last fetched time
      _logger.i('Successfully fetched store deliveries.');
    } catch (e) {
      _storeDeliveryError = 'Failed to load store deliveries: ${e.toString()}';
      _logger.e(_storeDeliveryError);
    } finally {
      _isLoadingStoreDeliveries = false;
      notifyListeners();
    }
  }

  /// Refreshes the data for the currently active tab.
  /// This will always force a refresh, bypassing stale time.
  Future<void> refreshOrders(OrderTabType tabType) async {
    if (tabType == OrderTabType.packageDelivery) {
      await fetchPackageDeliveries(forceRefresh: true);
    } else {
      await fetchStoreDeliveries(forceRefresh: true);
    }
  }

  /// Downloads the order report for a specific date range.
  Future<void> downloadReport(String startDate, String endDate) async {
    changeState(const ViewModelState.busy());
    try {
      await _deliveryService.downloadReport(startDate, endDate);
      
      // Handle success through DialogService
      _dialogService.showSuccess(
        'Download Successful', 
        'The report for $startDate to $endDate has been downloaded and opened.',
      );
      
      changeState(const ViewModelState.idle());
    } catch (e) {
      _logger.e('Failed to request report download: $e');
      
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Handle failure through DialogService
      _dialogService.showError('Request Failed', errorMessage);
      
      changeState(ViewModelState.error(FailureModel(message: errorMessage)));
    }
  }
}

final deliveryViewModelProvider = ChangeNotifierProvider((ref) {
  final deliveryService = ref.watch(deliveryServiceProvider);
  return DeliveryViewModel(
    deliveryService, 
    locator<DialogService>(),
    const AppLogger(DeliveryViewModel),
  );
});