import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:starter_codes/models/failure.dart';

class AudioServiceException with Failure {
  final String _title;
  final String _message;

  AudioServiceException(this._title, this._message);

  @override
  String get message => _message;

  @override
  String get title => _title;
}

class ChatException with Failure {
  final String _title;
  final String _message;

  ChatException(this._title, this._message);

  @override
  String get message => _message;

  @override
  String get title => _title;
}

class FileSaverException with Failure {
  final String _title;
  final String _message;

  FileSaverException(this._title, this._message);

  @override
  String get message => _message;

  @override
  String get title => _title;
}

class FilePickerException with Failure {
  final String _title;
  final String _message;

  FilePickerException(this._title, this._message);

  @override
  String get message => _message;

  @override
  String get title => _title;
}

class PaymentException with Failure {
  final String _title;
  final String _message;

  PaymentException(this._title, this._message);

  @override
  String get message => _message;

  @override
  String get title => _title;
}

class LocalPersistenceException with Failure {
  final String _title;
  final String _message;

  LocalPersistenceException(this._title, this._message);

  @override
  String get message => _message;

  @override
  String get title => _title;
}

class UserDefinedException with Failure {
  final String _title;
  final String _message;

  UserDefinedException(this._title, this._message);

  @override
  String get message => _message;

  @override
  String get title => _title;
}

/// 400
class BadRequestException extends DioException with Failure {
  BadRequestException(this.request, [this.serverResponse])
      : super(requestOptions: request, response: serverResponse);
  final RequestOptions request;
  final Response? serverResponse;

  @override
  String toString() {
    return 'title: $title message: $message';
  }

  @override
  String get message => serverResponse?.data?["message"] ?? "Invalid request";

  @override
  String get title => "An error occurred";
}

/// 500
class InternalServerErrorException extends DioException with Failure {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'title: $title message: $message';
  }

  @override
  String get message => "Unknown error occurred, please try again later.";

  @override
  String get title => "Server error";
}

/// 409
class ConflictException extends DioException with Failure {
  ConflictException(this.request, [this.serverResponse])
      : super(requestOptions: request, response: serverResponse);
  final RequestOptions request;
  final Response? serverResponse;

  @override
  String toString() {
    return 'title: $title message: $message';
  }

  @override
  String get message =>
      serverResponse?.data?["message"] ?? "Conflict occurred.";

  @override
  String get title => "Network error";
}

/// 401
class UnauthorizedException extends DioException with Failure {
  UnauthorizedException(this.request, [this.serverResponse])
      : super(requestOptions: request, response: serverResponse);
  final RequestOptions request;
  final Response? serverResponse;

  @override
  String toString() {
    return 'title: $title message: $message';
  }

  @override
  String get message => serverResponse?.data?["message"] ?? "Invalid request";

  @override
  String get title => "Access denied";
}

/// 404
class NotFoundException extends DioException with Failure {
  NotFoundException(this.request, [this.serverResponse])
      : super(requestOptions: request, response: serverResponse);
  final RequestOptions request;
  final Response? serverResponse;

  @override
  String toString() {
    return 'title: $title message: $message';
  }

  @override
  String get message =>
      serverResponse?.data?["message"] ?? "Not found, please try again.";

  @override
  String get title => "Not Found";
}

/// No Internet
class NoInternetConnectionException extends DioException with Failure {
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'title: $title message: $message';
  }

  @override
  String get message => "No internet connection, please try again.";

  @override
  String get title => "Network error";
}

/// Timeout
class DeadlineExceededException extends DioException with Failure {
  DeadlineExceededException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'title: $title message: $message';
  }

  @override
  String get message => "The connection has timed out, please try again.";

  @override
  String get title => "Network error";
}

/// Errors sent back by the server in json
class ServerCommunicationException extends DioException with Failure {
  ServerCommunicationException(this.r)
      : super(
          requestOptions: r?.requestOptions ?? RequestOptions(path: ''),
          response: r,
        );

  /// Sustained so that the data sent by the server can be gotten to construct message
  final Response? r;

  @override
  String toString() {
    return 'title: $title message: $message';
  }

  @override
  String get message {
    try {
      log(r?.data?.toString() ?? "No response data");

      if (r?.data == null) {
        return "Server communication error occurred";
      }

      return getMessagefromServer(r!.data);
    } catch (e) {
      log("Error parsing server message: $e");
      return "Something went wrong";
    }
  }

  @override
  String get title => "Network error";
}

/// 403 - Forbidden
class ForbiddenException extends DioException with Failure {
  ForbiddenException(this.request, [this.serverResponse])
      : super(requestOptions: request, response: serverResponse);
  final RequestOptions request;
  final Response? serverResponse;

  @override
  String toString() {
    return 'title: $title message: $message';
  }

  @override
  String get message => serverResponse?.data?["message"] ?? "Access forbidden";

  @override
  String get title => "Forbidden";
}

/// 422 - Unprocessable Entity
class UnprocessableEntityException extends DioException with Failure {
  UnprocessableEntityException(this.request, [this.serverResponse])
      : super(requestOptions: request, response: serverResponse);
  final RequestOptions request;
  final Response? serverResponse;

  @override
  String toString() {
    return 'title: $title message: $message';
  }

  @override
  String get message =>
      serverResponse?.data?["message"] ?? "Unprocessable entity";

  @override
  String get title => "Validation Error";
}
