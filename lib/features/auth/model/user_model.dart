// lib/features/auth/model/user_model.dart

class User {
  final String id; // Renamed from _id for Dart conventions
  final String email;
  final String role;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? firstname;
  final String? lastname;
  final String? phoneNumber; // Assuming phoneNumber might be part of the User
  final String? state;
  final Avatar? avatar;
  final bool isAdmin;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.firstname,
    this.lastname,
    this.phoneNumber,
    this.state,
    this.avatar,
    required this.isAdmin,
  });

  // NEW: Getter to get the first word of the 'state' field
  String? get currentState {
    if (state == null || state!.isEmpty) {
      return null;
    }
    // Split the string by space and take the first element
    return state!.split(' ')[0];
  }

  // Factory constructor for creating a new User instance from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isEmailVerified: json['isEmailVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      phoneNumber: json['phone'] as String?, // Assuming this field exists
      state: json['state'] as String?,
      avatar: json['avatar'] != null
          ? Avatar.fromJson(json['avatar'] as Map<String, dynamic>)
          : null,
      isAdmin: json['isAdmin'] as bool,
    );
  }

  // Method for converting a User instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'firstname': firstname,
      'lastname': lastname,
      'phoneNumber': phoneNumber,
      'state': state,
      'avatar': avatar?.toJson(),
      'isAdmin': isAdmin,
    };
  }

  // Method for creating a new User instance with updated properties
  User copyWith({
    String? id,
    String? email,
    String? role,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstname,
    String? lastname,
    String? phoneNumber,
    String? state,
    Avatar? avatar,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      state: state ?? this.state,
      avatar: avatar ?? this.avatar,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, role: $role, firstname: $firstname, lastname: $lastname)';
  }
}

// Nested model for Avatar details
class Avatar {
  final String imageUrl;
  final String cloudinaryId;

  Avatar({
    required this.imageUrl,
    required this.cloudinaryId,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      imageUrl: json['imageUrl'] as String,
      cloudinaryId: json['cloudinaryId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'cloudinaryId': cloudinaryId,
    };
  }

  Avatar copyWith({
    String? imageUrl,
    String? cloudinaryId,
  }) {
    return Avatar(
      imageUrl: imageUrl ?? this.imageUrl,
      cloudinaryId: cloudinaryId ?? this.cloudinaryId,
    );
  }

  @override
  String toString() {
    return 'Avatar(imageUrl: $imageUrl, cloudinaryId: $cloudinaryId)';
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