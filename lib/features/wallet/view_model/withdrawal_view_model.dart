import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wallet_service.dart';
import '../model/bank_model.dart';
import '../model/withdrawal_model.dart';
import '../data/bank_service.dart';
import 'package:starter_codes/core/utils/network_client.dart';

final bankServiceProvider = Provider((ref) {
  return BankService(NetworkClient());
});

class WithdrawalState {
  final AsyncValue<List<Bank>> bankList;
  final AsyncValue<UserBank?> userBank;
  final AsyncValue<WithdrawalResponse> withdrawalHistory;
  final Bank? selectedBank;
  final AsyncValue<Map<String, dynamic>> validationResult;
  final bool isLoading;

  WithdrawalState({
    required this.bankList,
    required this.userBank,
    required this.withdrawalHistory,
    this.selectedBank,
    required this.validationResult,
    this.isLoading = false,
  });

  WithdrawalState copyWith({
    AsyncValue<List<Bank>>? bankList,
    AsyncValue<UserBank?>? userBank,
    AsyncValue<WithdrawalResponse>? withdrawalHistory,
    Bank? selectedBank,
    AsyncValue<Map<String, dynamic>>? validationResult,
    bool? isLoading,
  }) {
    return WithdrawalState(
      bankList: bankList ?? this.bankList,
      userBank: userBank ?? this.userBank,
      withdrawalHistory: withdrawalHistory ?? this.withdrawalHistory,
      selectedBank: selectedBank ?? this.selectedBank,
      validationResult: validationResult ?? this.validationResult,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WithdrawalNotifier extends StateNotifier<WithdrawalState> {
  final BankService bankService;
  final WalletService walletService;

  WithdrawalNotifier(this.bankService, this.walletService)
      : super(
          WithdrawalState(
            bankList: const AsyncValue.loading(),
            userBank: const AsyncValue.loading(),
            withdrawalHistory: const AsyncValue.loading(),
            validationResult: const AsyncValue.data({}),
          ),
        ) {
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      _fetchBankList(),
      _fetchUserBank(),
      _fetchWithdrawalHistory(),
    ]);
  }

  Future<void> _fetchBankList() async {
    state = state.copyWith(
      bankList: const AsyncValue.loading(),
    );
    final result = await AsyncValue.guard(
      () => bankService.getBankList(),
    );
    state = state.copyWith(bankList: result);
  }

  Future<void> _fetchUserBank() async {
    state = state.copyWith(
      userBank: const AsyncValue.loading(),
    );
    final result = await AsyncValue.guard(
      () => bankService.getUserBank(),
    );
    state = state.copyWith(userBank: result);
  }

  Future<void> _fetchWithdrawalHistory() async {
    state = state.copyWith(
      withdrawalHistory: const AsyncValue.loading(),
    );
    final result = await AsyncValue.guard(() async {
      try {
        final data = await walletService.getWithdrawalHistory();
        // Check if data is empty which might indicate an error caught in service but returned as empty map
        if (data.isEmpty) {
          // We might want to allow empty map if it's truly empty, but if it was an error handled in service it returns {}.
          // Ideally service should rethrow or return result object. For now, let's proceed.
        }
        return WithdrawalResponse.fromJson(data);
      } catch (e) {
        // Log here because AsyncValue.guard swallows it into an AsyncError, which we see in UI but maybe not in console logs if we don't print.
        // Actually AppLogger should be used.
        // Since I don't have logger here easily without inject, I'll rely on service logs.
        // But wait, I can see `AsyncValue.guard` is just a helper.
        rethrow;
      }
    });
    state = state.copyWith(withdrawalHistory: result);
  }

  void selectBank(Bank bank) {
    state = state.copyWith(selectedBank: bank);
    state = state.copyWith(validationResult: const AsyncValue.data({}));
  }

  Future<void> validateBank(String accountNumber, String bankCode) async {
    state = state.copyWith(validationResult: const AsyncValue.loading());
    final result = await AsyncValue.guard(
      () => bankService.validateBankAccount(accountNumber, bankCode),
    );
    state = state.copyWith(validationResult: result);
  }

  Future<void> createBank(
    String bankCode,
    String accountNumber,
    String accountName,
    String bankName,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
      await bankService.createUserBank(
        bankCode,
        accountNumber,
        accountName,
        bankName,
      );
      await _fetchUserBank();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateBank(
    String bankCode,
    String accountNumber,
    String accountName,
    String bankName,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
      await bankService.updateUserBank(
        bankCode,
        accountNumber,
        accountName,
        bankName,
      );
      await _fetchUserBank();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> requestWithdrawal(double amount) async {
    state = state.copyWith(isLoading: true);
    try {
      final userBankValue = state.userBank;
      if (userBankValue is AsyncData<UserBank?>) {
        await walletService.requestWithdrawal(amount);
        await _fetchWithdrawalHistory();
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      _fetchUserBank(),
      _fetchWithdrawalHistory(),
    ]);
  }

  void clearSession() {
    state = WithdrawalState(
      bankList: state.bankList,
      userBank: state.userBank,
      withdrawalHistory: state.withdrawalHistory,
      selectedBank: null,
      validationResult: const AsyncValue.data({}),
      isLoading: false,
    );
  }
}

final withdrawalProvider =
    StateNotifierProvider<WithdrawalNotifier, WithdrawalState>((ref) {
  final bankService = ref.watch(bankServiceProvider);
  final walletService = ref.watch(walletServiceProvider);
  return WithdrawalNotifier(bankService, walletService);
});
