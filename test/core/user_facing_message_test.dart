import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/models/failure.dart';

void main() {
  group('userFacingMessage', () {
    const fallback = 'We could not complete that request.';

    test('passes through copy written for a user', () {
      const copy = 'This email address is already registered.';
      expect(userFacingMessage(copy, fallback), copy);
    });

    test('hides the Mongoose buffering timeout that reached signup', () {
      expect(
        userFacingMessage(
          'Operation `users.findOne()` buffering timed out after 10000ms',
          fallback,
        ),
        fallback,
      );
    });

    test('hides driver, runtime and stack detail', () {
      const machine = [
        'connect ECONNREFUSED 127.0.0.1:27017',
        'MongoServerError: E11000 duplicate key error collection',
        "TypeError: Cannot read properties of undefined (reading 'id')",
        'Error\n    at Object.handler (/app/node_modules/express/index.js:1:1)',
      ];
      for (final message in machine) {
        expect(userFacingMessage(message, fallback), fallback, reason: message);
      }
    });

    test('falls back on an empty or non-string message', () {
      expect(userFacingMessage('   ', fallback), fallback);
      expect(userFacingMessage(null, fallback), fallback);
      expect(userFacingMessage({'code': 500}, fallback), fallback);
    });

    test('falls back on a dump too long to be product copy', () {
      expect(userFacingMessage('a' * 201, fallback), fallback);
    });
  });
}
