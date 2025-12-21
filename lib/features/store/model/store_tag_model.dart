class StoreTag {
  final String name;
  final String value;
  final String imageUrl;

  const StoreTag({
    required this.name,
    required this.value,
    required this.imageUrl,
  });

  factory StoreTag.fromJson(Map<String, dynamic> json) {
    return StoreTag(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'image_url': imageUrl,
    };
  }

  // For backward compatibility with existing code
  String get tagValue => value;
}

class StoreTagsResponse {
  final bool success;
  final String message;
  final List<StoreTag> data;

  const StoreTagsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StoreTagsResponse.fromJson(Map<String, dynamic> json) {
    return StoreTagsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => StoreTag.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
