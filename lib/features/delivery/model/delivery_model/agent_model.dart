import 'package:equatable/equatable.dart';
// import 'package:intl/intl.dart'; // Uncomment if you use DateFormat for date/time parsing

// --- Bulk Order Sub-Models ---

// The rider or shopper carrying an order.

class AgentModel extends Equatable {
  final String? id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String? phone;
  final String? imageUrl; // Direct access to avatar imageUrl

  const AgentModel({
    this.id,
    this.email,
    this.firstname,
    this.lastname,
    this.phone,
    this.imageUrl,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['_id'] as String?,
      email: json['email'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      phone: json['phone'] as String?,
      imageUrl:
          (json['avatar'] as Map<String, dynamic>?)?['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'avatar': {
        'imageUrl': imageUrl,
      },
    };
  }

  String get fullName {
    if (firstname != null && lastname != null) {
      return '$firstname $lastname';
    } else if (firstname != null) {
      return firstname!;
    } else if (lastname != null) {
      return lastname!;
    } else {
      return 'Unknown Agent';
    }
  }

  @override
  List<Object?> get props => [id, email, firstname, lastname, phone, imageUrl];
}

// --- Main DeliveryModel ---
