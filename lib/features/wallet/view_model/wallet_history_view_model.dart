import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wallet_service.dart';
import '../model/payment_history_model.dart';
import 'package:starter_codes/core/utils/app_logger.dart';

// State class to hold both withdrawal history and wallet balance
class WalletOverviewState {
  final AsyncValue<List<PaymentHistory>> withdrawalHistory;
  final AsyncValue<double> walletBalance; // Assuming this is also managed here

  WalletOverviewState({
    this.withdrawalHistory = const AsyncValue.loading(),
    this.walletBalance = const AsyncValue.loading(),
  });

  // Helper to create a new state with updated values (immutability is key)
  WalletOverviewState copyWith({
    AsyncValue<List<PaymentHistory>>? withdrawalHistory,
    AsyncValue<double>? walletBalance,
  }) {
    return WalletOverviewState(
      withdrawalHistory: withdrawalHistory ?? this.withdrawalHistory,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}

// The NotifierProvider for the WalletOverviewViewModel
final walletOverviewViewModelProvider =
    NotifierProvider<WalletOverviewNotifier, WalletOverviewState>(() {
  return WalletOverviewNotifier();
});

// The Notifier class that manages the state
class WalletOverviewNotifier extends Notifier<WalletOverviewState> {
  late final WalletService _walletService;
  late final AppLogger _logger;

  // --- New: Stale Time Logic ---
  DateTime? _lastFetchedHistoryTime;
  final Duration _staleTime =
      const Duration(minutes: 2); // History considered stale after 2 minutes

  @override
  WalletOverviewState build() {
    _logger =
        const AppLogger(WalletOverviewNotifier); // Initialize logger first
    _logger.d('🟠 WalletOverviewNotifier: BUILD METHOD CALLED'); // Debug print

    // Initialize WalletService using ref.read AFTER logger is set up
    _walletService = ref.read(walletServiceProvider);

    _logger
        .d('🟠 WalletOverviewNotifier: Scheduling _fetchHistoryAndBalance...');

    // Schedule the initial data fetch AFTER the build method returns the initial state
    Future.microtask(() {
      _fetchHistoryAndBalance();
    });

    // Return the initial loading state. This is what 'state' is *initialized* to.
    return WalletOverviewState();
  }

  /// Helper to check if data is stale
  bool _isHistoryStale() {
    if (_lastFetchedHistoryTime == null) return true;
    return DateTime.now().difference(_lastFetchedHistoryTime!) > _staleTime;
  }

  // Method to fetch both history and balance
  /// [forceRefresh] - Set to true to bypass stale time check and force a network fetch.
  Future<void> _fetchHistoryAndBalance({bool forceRefresh = false}) async {
    _logger.d(
        'WalletOverviewNotifier: _fetchHistoryAndBalance initiated (forceRefresh: $forceRefresh).');

    // --- Stale Time Check for History ---
    if (!forceRefresh &&
        !_isHistoryStale() &&
        state.withdrawalHistory.hasValue) {
      _logger.i('Wallet history is not stale and has data. Using cached data.');
      return;
    }

    // Only set loading if we are actually going to fetch new data
    if (!state.withdrawalHistory.isLoading) {
      state = state.copyWith(withdrawalHistory: const AsyncValue.loading());
    }

    // --- Fetch Wallet Balance ---
    try {
      if (!state.walletBalance.isLoading) {
        state = state.copyWith(walletBalance: const AsyncValue.loading());
      }

      final balance = await _walletService.fetchWalletBalance();
      state = state.copyWith(walletBalance: AsyncValue.data(balance));
      _logger.d(
          'WalletOverviewNotifier: Wallet balance fetched successfully: $balance');
    } catch (e, st) {
      _logger.e('WalletOverviewNotifier: Error fetching wallet balance.',
          error: e, stackTrace: st);
      state = state.copyWith(walletBalance: AsyncValue.error(e, st));
    }

    try {
      final history = await _walletService.fetchPaymentHistory();
      state = state.copyWith(withdrawalHistory: AsyncValue.data(history));
      _lastFetchedHistoryTime = DateTime.now(); // Update last fetched time
      _logger
          .d('WalletOverviewNotifier: Payment history fetched successfully.');
    } catch (e, st) {
      _logger.e('WalletOverviewNotifier: Error fetching payment history.',
          error: e, stackTrace: st);
      state = state.copyWith(withdrawalHistory: AsyncValue.error(e, st));
    }
  }

  Future<void> refreshData() async {
    _logger.d(
        'WalletOverviewNotifier: Refresh data requested. Re-initiating fetch.');
    await _fetchHistoryAndBalance(forceRefresh: true);
  }
}
