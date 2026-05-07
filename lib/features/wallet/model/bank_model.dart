class Bank {
  final String id;
  final String name;
  final String code;
  final String? slug;
  final bool? supportsTransfer;
  final String? gateway;
  final bool? active;

  Bank({
    required this.id,
    required this.name,
    required this.code,
    this.slug,
    this.supportsTransfer,
    this.gateway,
    this.active,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      slug: json['slug']?.toString(),
      supportsTransfer: json['supports_transfer'],
      gateway: json['gateway']?.toString(),
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'slug': slug,
      'supports_transfer': supportsTransfer,
      'gateway': gateway,
      'active': active,
    };
  }
}

class UserBank {
  final String? id;
  final String bankName;
  final String bankCode;
  final String accountName;
  final String accountNumber;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserBank({
    this.id,
    required this.bankName,
    required this.bankCode,
    required this.accountName,
    required this.accountNumber,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserBank.fromJson(Map<String, dynamic> json) {
    return UserBank(
      id: json['_id'] ?? json['id'],
      bankName: json['bankName'] ?? '',
      bankCode: json['bankCode'] ?? '',
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      userId: json['user'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bankName': bankName,
      'bankCode': bankCode,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'user': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
