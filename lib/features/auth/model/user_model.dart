// lib/features/auth/model/user_model.dart

class User {
  final String id;
  final String email;
  final String role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isKYCVerified;
  final bool isAdmin;
  final bool isDeleted;
  final int totalOrders;
  final bool hasCoupon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? firstname;
  final String? lastname;
  final String? phoneNumber;
  final String? state;
  final String ordersSincePromo;
  final String? fcmToken;
  final Avatar? avatar;
  final Wallet? wallet;
  final dynamic kyc; // Can be null or an object

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isKYCVerified,
    required this.isAdmin,
    required this.isDeleted,
    required this.totalOrders,
    required this.hasCoupon,
    required this.createdAt,
    required this.updatedAt,
    this.firstname,
    this.lastname,
    this.phoneNumber,
    this.state,
    this.ordersSincePromo = '0',
    this.fcmToken,
    this.avatar,
    this.wallet,
    this.kyc,
  });

  // Getter to get the first word of the 'state' field
  String? get currentState {
    if (state == null || state!.isEmpty) {
      return null;
    }
    return state!.split(' ')[0];
  }

  // Getter for full name
  String get fullName {
    if (firstname == null && lastname == null) return 'User';
    if (firstname != null && lastname != null) {
      return '$firstname $lastname';
    }
    return firstname ?? lastname ?? 'User';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String? ?? json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      isKYCVerified: json['isKYCVerified'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      totalOrders: json['totalOrders'] as int? ?? 0,
      hasCoupon: json['hasCoupon'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      phoneNumber: json['phone'] as String?,
      state: json['state'] as String?,
      ordersSincePromo: json['ordersSincePromo']?.toString() ?? '0',
      fcmToken: json['fcmToken'] as String?,
      avatar: json['avatar'] != null
          ? Avatar.fromJson(json['avatar'] as Map<String, dynamic>)
          : null,
      wallet: json['wallet'] != null
          ? Wallet.fromJson(json['wallet'] as Map<String, dynamic>)
          : null,
      kyc: json['kyc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isKYCVerified': isKYCVerified,
      'isAdmin': isAdmin,
      'isDeleted': isDeleted,
      'totalOrders': totalOrders,
      'hasCoupon': hasCoupon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'firstname': firstname,
      'lastname': lastname,
      'phone': phoneNumber,
      'state': state,
      'ordersSincePromo': ordersSincePromo,
      'fcmToken': fcmToken,
      'avatar': avatar?.toJson(),
      'wallet': wallet?.toJson(),
      'kyc': kyc,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isKYCVerified,
    bool? isAdmin,
    bool? isDeleted,
    int? totalOrders,
    bool? hasCoupon,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstname,
    String? lastname,
    String? phoneNumber,
    String? state,
    String? ordersSincePromo,
    String? fcmToken,
    Avatar? avatar,
    Wallet? wallet,
    dynamic kyc,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isKYCVerified: isKYCVerified ?? this.isKYCVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      isDeleted: isDeleted ?? this.isDeleted,
      totalOrders: totalOrders ?? this.totalOrders,
      hasCoupon: hasCoupon ?? this.hasCoupon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      state: state ?? this.state,
      ordersSincePromo: ordersSincePromo ?? this.ordersSincePromo,
      fcmToken: fcmToken ?? this.fcmToken,
      avatar: avatar ?? this.avatar,
      wallet: wallet ?? this.wallet,
      kyc: kyc ?? this.kyc,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, role: $role, firstname: $firstname, lastname: $lastname)';
  }
}

// Wallet Model
class Wallet {
  final String id;
  final double balance;

  Wallet({
    required this.id,
    required this.balance,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['_id'] as String? ?? json['id'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'balance': balance,
    };
  }

  Wallet copyWith({
    String? id,
    double? balance,
  }) {
    return Wallet(
      id: id ?? this.id,
      balance: balance ?? this.balance,
    );
  }
}

// Avatar Model (assuming you already have this, but here's a complete version)
class Avatar {
  final String imageUrl;
  final String? publicId;

  Avatar({
    required this.imageUrl,
    this.publicId,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      imageUrl: json['imageUrl'] as String? ?? json['url'] as String? ?? '',
      publicId: json['publicId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'publicId': publicId,
    };
  }
}

class SignupRequest {
  final String email;
  final String password;

  SignupRequest({
    required this.email,
    required this.password,
  });
  // Converts this SignupRequest object into a JSON-compatible Map.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  // Optional: fromJson factory for parsing if you ever need to create
  // a SignupRequest from a JSON (less common for request bodies).
  factory SignupRequest.fromJson(Map<String, dynamic> json) {
    return SignupRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  // Optional: copyWith method for immutability and easy updates
  SignupRequest copyWith({
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) {
    return SignupRequest(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}