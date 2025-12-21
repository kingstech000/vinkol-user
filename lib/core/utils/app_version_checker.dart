import 'package:package_info_plus/package_info_plus.dart';
import 'package:starter_codes/features/app/model/app_details_model.dart';

class AppVersionChecker {
  static Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String> getCurrentBuildNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  static bool isUpdateRequired(
    AppDetailsModel requiredAppDetails,
    String currentVersion,
    String currentBuildNumber,
  ) {
    final requiredVersion = requiredAppDetails.versionNumber;
    final requiredBuildNumber = requiredAppDetails.buildNumber;

    if (currentVersion != requiredVersion) {
      return true;
    }

    if (currentBuildNumber != requiredBuildNumber) {
      return true;
    }

    return false;
  }
}

