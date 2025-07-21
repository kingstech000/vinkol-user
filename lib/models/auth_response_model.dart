class AuthResponse {
  String token;

  AuthResponse({
    required this.token,
  });

  AuthResponse copyWith({
    String? token,
  }) =>
      AuthResponse(
        token: token ?? this.token,
      );

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
      };
}
