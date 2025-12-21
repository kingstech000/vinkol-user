class RiderRatingModel {
  final double avgRating;
  final int ratingsCount;

  const RiderRatingModel({
    required this.avgRating,
    required this.ratingsCount,
  });

  factory RiderRatingModel.fromJson(Map<String, dynamic> json) {
    return RiderRatingModel(
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: (json['ratingsCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avgRating': avgRating,
      'ratingsCount': ratingsCount,
    };
  }
}

class RiderRatingResponse {
  final bool success;
  final String message;
  final RiderRatingModel data;

  const RiderRatingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RiderRatingResponse.fromJson(Map<String, dynamic> json) {
    return RiderRatingResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: RiderRatingModel.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class RiderRatingRequest {
  final String rider;
  final int starRating;
  final String comment;

  const RiderRatingRequest({
    required this.rider,
    required this.starRating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rider': rider,
      'starRating': starRating,
      'comment': comment,
    };
  }
}

