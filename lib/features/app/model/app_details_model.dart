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
    final buildNumberValue = json['BUILD_NUMBER'];
    return AppDetailsModel(
      versionNumber: json['VERSION_NUMBER'] as String? ?? '',
      buildNumber: buildNumberValue?.toString() ?? '',
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

class PlatformAppDetails {
  final AppDetailsModel customerApp;
  final AppDetailsModel riderApp;

  const PlatformAppDetails({
    required this.customerApp,
    required this.riderApp,
  });

  factory PlatformAppDetails.fromJson(Map<String, dynamic> json) {
    return PlatformAppDetails(
      customerApp: AppDetailsModel.fromJson(
        json['CUSTOMER_APP'] as Map<String, dynamic>? ?? {},
      ),
      riderApp: AppDetailsModel.fromJson(
        json['RIDER_APP'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class AppDetailsData {
  final PlatformAppDetails android;
  final PlatformAppDetails ios;

  const AppDetailsData({
    required this.android,
    required this.ios,
  });

  factory AppDetailsData.fromJson(Map<String, dynamic> json) {
    final appDetails = json['APP_DETAILS'] as Map<String, dynamic>? ?? {};
    return AppDetailsData(
      android: PlatformAppDetails.fromJson(
        appDetails['ANDROID'] as Map<String, dynamic>? ?? {},
      ),
      ios: PlatformAppDetails.fromJson(
        appDetails['IOS'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  PlatformAppDetails getPlatformDetails(bool isAndroid) {
    return isAndroid ? android : ios;
  }
}

