import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/utils/app_version_checker.dart';
import 'package:starter_codes/features/app/model/app_details_model.dart';

void main() {
  group('AppVersionChecker.isUpdateRequired', () {
    void testVersion(String currentV, String currentB, String reqV, String reqB,
        bool expected, String description) {
      test(description, () {
        final model = AppDetailsModel(
            versionNumber: reqV, buildNumber: reqB, appName: 'Test');
        final result =
            AppVersionChecker.isUpdateRequired(model, currentV, currentB);
        expect(result, expected);
      });
    }

    // Version comparisons
    testVersion('1.0.0', '1', '1.0.1', '1', true, 'Lower version, same build');
    testVersion(
        '1.0.1', '1', '1.0.0', '1', false, 'Higher version, same build');
    testVersion('1.1.0', '1', '1.0.5', '1', false, 'Higher minor version');
    testVersion('0.9.0', '1', '1.0.0', '1', true, 'Lower major version');

    // Build number comparisons (same version)
    testVersion('1.0.0', '1', '1.0.0', '2', true, 'Same version, lower build');
    testVersion(
        '1.0.0', '2', '1.0.0', '1', false, 'Same version, higher build');
    testVersion('1.0.0', '1', '1.0.0', '1', false, 'Same version, same build');

    // Edge cases
    testVersion('1.0', '1', '1.0.1', '1', true, 'Shorter current version');
    testVersion('1.0.1', '1', '1.0', '1', false, 'Longer current version');
    testVersion('1.0.0', 'a', '1.0.0', '2', true,
        'Invalid build number (defaults to 0)');
  });
}
