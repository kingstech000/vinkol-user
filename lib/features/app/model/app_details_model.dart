class AppDetailsModel {
  final String versionNumber;
  final String buildNumber;
  final String appName;

  const AppDetailsModel({
    required this.versionNumber,
    required this.buildNumber,
    required this.appName,
  });

  factory AppDetailsModel.fromJson(Map<String, dynamic> json) {
    return AppDetailsModel(
      versionNumber: json['VERSION_NUMBER'] as String? ?? '',
      buildNumber: json['BUILD_NUMBER'] as String? ?? '',
      appName: json['APP_NAME'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'VERSION_NUMBER': versionNumber,
      'BUILD_NUMBER': buildNumber,
      'APP_NAME': appName,
    };
  }
}

class AppDetailsResponse {
  final bool success;
  final String message;
  final AppDetailsData data;

  const AppDetailsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AppDetailsResponse.fromJson(Map<String, dynamic> json) {
    return AppDetailsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: AppDetailsData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class AppDetailsData {
  final AppDetailsModel customerApp;
  final AppDetailsModel riderApp;

  const AppDetailsData({
    required this.customerApp,
    required this.riderApp,
  });

  factory AppDetailsData.fromJson(Map<String, dynamic> json) {
    final appDetails = json['APP_DETAILS'] as Map<String, dynamic>? ?? {};
    return AppDetailsData(
      customerApp: AppDetailsModel.fromJson(
        appDetails['CUSTOMER_APP'] as Map<String, dynamic>? ?? {},
      ),
      riderApp: AppDetailsModel.fromJson(
        appDetails['RIDER_APP'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

