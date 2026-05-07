import 'package:starter_codes/core/utils/network_client.dart';
import '../model/bank_model.dart';
import '../../../core/constants/api_routes.dart';

class BankService {
  final NetworkClient networkClient;

  BankService(this.networkClient);

  Future<List<Bank>> getBankList() async {
    try {
      final response = await networkClient.get(ApiRoute.banksList);
      if (response is Map<String, dynamic>) {
        final banksData = response['data'] ?? response;
        if (banksData is List) {
          return banksData.map((e) => Bank.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch banks: $e');
    }
  }

  Future<UserBank?> getUserBank() async {
    try {
      final response = await networkClient.get(ApiRoute.userBank);
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] != null) {
          final data = response['data'];
          if (data is Map<String, dynamic> && data.isNotEmpty) {
            return UserBank.fromJson(data);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> validateBankAccount(
    String accountNumber,
    String bankCode,
  ) async {
    try {
      final response = await networkClient.post(
        ApiRoute.validateBank,
        body: {
          'accountNumber': accountNumber,
          'bankCode': bankCode,
        },
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      throw Exception('Bank validation failed');
    } catch (e) {
      throw Exception('Validation error: $e');
    }
  }

  Future<UserBank> createUserBank(
    String bankCode,
    String accountNumber,
    String accountName,
    String bankName,
  ) async {
    try {
      final response = await networkClient.post(
        ApiRoute.createUserBank,
        body: {
          'bankCode': bankCode,
          'accountNumber': accountNumber,
          'accountName': accountName,
          'bankName': bankName,
        },
      );
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return UserBank.fromJson(response['data']);
        } else {
          return UserBank.fromJson(response);
        }
      }
      throw Exception('Failed to create bank account');
    } catch (e) {
      throw Exception('Create bank error: $e');
    }
  }

  Future<UserBank> updateUserBank(
    String bankCode,
    String accountNumber,
    String accountName,
    String bankName,
  ) async {
    try {
      final response = await networkClient.patch(
        ApiRoute.userBank,
        body: {
          'bankCode': bankCode,
          'accountNumber': accountNumber,
          'accountName': accountName,
          'bankName': bankName,
        },
      );
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return UserBank.fromJson(response['data']);
        } else {
          return UserBank.fromJson(response);
        }
      }
      throw Exception('Failed to update bank account');
    } catch (e) {
      throw Exception('Update bank error: $e');
    }
  }
}
