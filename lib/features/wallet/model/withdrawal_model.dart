class Withdrawal {
  final String? id;
  final String? userId;
  final String? bankId;
  final double amount;
  final String? reason;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? bankName;
  final String? accountNumber;

  Withdrawal({
    this.id,
    this.userId,
    this.bankId,
    required this.amount,
    this.reason,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.bankName,
    this.accountNumber,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    String? getObjectId(dynamic value) {
      if (value is Map) {
        return value['_id'];
      } else if (value is String) {
        return value;
      }
      return null;
    }

    return Withdrawal(
      id: json['_id'] ?? json['id'],
      userId: getObjectId(json['user']),
      bankId: getObjectId(json['bank']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'],
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      bankName: json['bankName'] ??
          (json['bank'] is Map ? json['bank']['bankName'] : null),
      accountNumber: json['accountNumber'] ??
          (json['bank'] is Map ? json['bank']['accountNumber'] : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'bank': bankId,
      'amount': amount,
      'reason': reason,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'bankName': bankName,
      'accountNumber': accountNumber,
    };
  }
}

class WithdrawalResponse {
  final List<Withdrawal> data;
  final int total;
  final int page;
  final int pageSize;

  WithdrawalResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> fetchedDataList = [];
    int totalCount = 0;
    int pageNo = 1;
    int pageSizeVal = 10;

    if (json['data'] is List) {
      fetchedDataList = json['data'] as List;
      totalCount = json['total'] ?? fetchedDataList.length;
      pageNo = json['page'] ?? 1;
      pageSizeVal = json['limit'] ?? json['pageSize'] ?? 10;
    } else if (json['data'] is Map<String, dynamic>) {
      final dataObj = json['data'] as Map<String, dynamic>;
      fetchedDataList = dataObj['fetchedData'] as List? ?? [];
      totalCount = dataObj['total'] ?? json['total'] ?? 0;
      pageNo = dataObj['page_no'] ?? json['page'] ?? 1;
      pageSizeVal = dataObj['page_size'] ?? json['pageSize'] ?? 10;
    }

    return WithdrawalResponse(
      data: fetchedDataList.map((e) => Withdrawal.fromJson(e)).toList(),
      total: totalCount,
      page: pageNo,
      pageSize: pageSizeVal,
    );
  }
}
