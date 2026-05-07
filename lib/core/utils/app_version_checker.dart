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

    // Compare versions (semver-ish)
    final versionComparison = _compareVersions(currentVersion, requiredVersion);

    if (versionComparison < 0) {
      // Current version is strictly less than required version
      return true;
    }

    if (versionComparison > 0) {
      // Current version is strictly greater than required version
      return false;
    }

    // Versions are identical, compare build numbers
    final currentBuild = int.tryParse(currentBuildNumber) ?? 0;
    final requiredBuild = int.tryParse(requiredBuildNumber) ?? 0;

    return currentBuild < requiredBuild;
  }

  /// Compares two version strings (e.g., "1.0.1" and "1.1.0").
  /// Returns:
  /// -1 if v1 < v2
  ///  0 if v1 == v2
  ///  1 if v1 > v2
  static int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final length =
        v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;

    for (var i = 0; i < length; i++) {
      final part1 = i < v1Parts.length ? v1Parts[i] : 0;
      final part2 = i < v2Parts.length ? v2Parts[i] : 0;

      if (part1 < part2) return -1;
      if (part1 > part2) return 1;
    }
    return 0;
  }
}
