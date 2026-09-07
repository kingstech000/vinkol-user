import 'package:starter_codes/models/exception.dart';

/// Shown when the server's message turns out to be written for a developer.
const String kGenericErrorMessage = "Something went wrong. Please try again.";

/// Markers of a message that came from the stack rather than from product copy —
/// driver timeouts, ORM internals, runtime type errors, stack frames. The server
/// returns these in the same `message` field as copy we do want to show, so the
/// only way to tell them apart is to look at them.
const List<String> _machineMessageMarkers = [
  'buffering timed out',
  'mongo',
  'mongoose',
  'sequelize',
  'prisma',
  'redis',
  'casterror',
  'e11000',
  'econnrefused',
  'econnreset',
  'etimedout',
  'esockettimedout',
  'enotfound',
  'eai_again',
  'typeerror',
  'referenceerror',
  'syntaxerror',
  'rangeerror',
  'cannot read propert',
  'is not a function',
  'is not defined',
  'undefined',
  'null pointer',
  'stack trace',
  'node_modules',
  'at object.',
  '.js:',
  'localhost',
  '127.0.0.1',
];

/// Whether [message] reads like machine detail that should never reach a user.
bool isMachineErrorMessage(String message) {
  final normalized = message.toLowerCase();
  // `users.findOne()` and friends — a code signature quoted back at us.
  if (normalized.contains('`') && normalized.contains('()')) return true;
  if (normalized.contains('\n    at ')) return true;
  // Product copy is a sentence or two; anything longer is a dump.
  if (message.length > 200) return true;
  return _machineMessageMarkers.any(normalized.contains);
}

/// [serverMessage] if it reads like something we wrote for a user, else [fallback].
/// The raw text is still logged by the interceptor either way.
String userFacingMessage(dynamic serverMessage, String fallback) {
  if (serverMessage is! String) return fallback;
  final message = serverMessage.trim();
  if (message.isEmpty) return fallback;
  return isMachineErrorMessage(message) ? fallback : message;
}

mixin Failure {
  String get message;

  String get title;

  bool get isInternetConnectionError =>
      runtimeType is NoInternetConnectionException;

  String getMessagefromServer(dynamic error) {
    if (error is! Map) return kGenericErrorMessage;
    return userFacingMessage(error["message"], kGenericErrorMessage);
  }
}
