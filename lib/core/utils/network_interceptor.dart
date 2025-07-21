import 'package:dio/dio.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/models/exception.dart';
import 'package:starter_codes/models/failure.dart';

class AppInterceptors extends Interceptor {
  final _log = appLogger(AppInterceptors);
  final Dio dio;

  AppInterceptors(this.dio);

  @override
  onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // checkStatusCode(response.requestOptions, response);
    // print(÷.realUri);

    _log.custom(
      "--------- Calling Api [${DateTime.now()}]----------",
      color: LoggerColor.darkGrey,
      functionName: "onRequest",
    );
    _log.custom(
      "${options.method}: ${options.path}",
      color: LoggerColor.darkGrey,
      functionName: "onRequest",
    );
    _log.custom(
      options.uri,
      color: LoggerColor.darkGrey,
      functionName: "onRequest",
    );
    return handler.next(options);
  }

  @override
  Future<dynamic> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    checkStatusCode(response.requestOptions, response);

    _log.custom(
      "--------- Api Response [${DateTime.now()}]----------",
      color: LoggerColor.darkGrey,
      functionName: "onResponse",
    );
    _log.custom(
      response.requestOptions.uri,
      color: LoggerColor.darkGrey,
      functionName: "onResponse",
    );
    return handler.next(response);
  }

  @override
  Future onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _log.e(err.requestOptions.headers, functionName: "onError[1]");
    _log.e(err.requestOptions.data, functionName: "onError[2]");
    _log.e(err.response?.data, functionName: "onError[3]");
    _log.e(err.response?.statusCode, functionName: "onError[4]");

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // reasign err variable
        err = DeadlineExceededException(err.requestOptions);
        break;
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
      case DioExceptionType.badResponse:
        try {
          checkStatusCode(err.requestOptions, err.response);
        } on DioException catch (failure) {
          // reasign err variable
          err = failure;
        }

        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.unknown:
        _log.e(err.message, functionName: "onError[other]");
        err = NoInternetConnectionException(err.requestOptions);
    }
    //continue
    return handler.next(err);
  }

  void checkStatusCode(RequestOptions requestOptions, Response? response) {
    try {
      switch (response?.statusCode) {
        case 200:
        case 204:
        case 201:
          break;
        case 400:
          throw BadRequestException(requestOptions, response);
        case 401:
          throw UnauthorizedException(requestOptions, response);
        case 404:
          throw NotFoundException(requestOptions);
        case 409:
          throw ConflictException(requestOptions, response);
        case 500:
          throw InternalServerErrorException(requestOptions);
        default:
          _log.e(response?.data, functionName: "onError[checkStatusCode]");
          _log.e(response?.statusCode,
              functionName: "onError[checkStatusCode]");
          throw ServerCommunicationException(response);
      }
    } on Failure {
      rethrow;
    }
  }
}
