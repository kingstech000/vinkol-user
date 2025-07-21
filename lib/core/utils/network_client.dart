import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:starter_codes/core/constants/api_routes.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/models/failure.dart';

import 'network_interceptor.dart';

enum FormDataType { post, patch }

class NetworkClient {
  NetworkClient._internal();
  static final _singleton = NetworkClient._internal();

  factory NetworkClient() => _singleton;

  late final LocalCache _localCache = locator();

  final Dio _dio = createDio();
// ======================================================
//================== Dio Initialization =================
//=======================================================

  static Dio createDio() {
    var dio = Dio(BaseOptions(
      baseUrl: ApiRoute.baseUrl,
      receiveTimeout: const Duration(milliseconds: 40000), // 15 seconds
      connectTimeout: const Duration(milliseconds: 40000),
      sendTimeout: const Duration(milliseconds: 40000),
    ));

    dio.interceptors.addAll({
      AppInterceptors(dio),
    });
    return dio;
  }

  Map<String, String> get _getAuthHeader {
    final token = _localCache.getToken();
    if (token != null && token.isNotEmpty) {
      return {
        "Authorization": "Bearer $token",
      };
    }

    return {};
  }

// ======================================================
//======================== Get ==========================
//=======================================================
  ///get request
  Future<T> get<T>(
    /// the api route path without the base url
    ///
    String uri, {
    Map<String, dynamic> queryParameters = const {},
    // Options options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          headers: {
            ..._getAuthHeader,
          },
        ),
      );

      return response.data;
    } on Failure {
      rethrow;
    }
  }

// ======================================================
//======================== POST ==========================
//=======================================================
  ///Post request
  Future<dynamic> post(
    /// the api route without the base url
    String uri, {
    ///this are query parameters that would
    /// be attached to the url
    /// [e.g]=>{"a":"yes"}
    /// https://she.com/getPeople?a=yes
    Map<String, dynamic> queryParameters = const {},
    Object? body,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.post(
        uri,
        queryParameters: queryParameters,
        data: body,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          headers: {
            ..._getAuthHeader,
          },
        ),
      );

      log(response.statusCode.toString());
      return response.data;
    } on Failure {
      rethrow;
    }
  }

// ======================================================
//======================== PUT ==========================
//=======================================================
  ///Put Request
  Future<T> put<T>(
    /// the api route without the base url
    String uri, {
    ///this are query parameters that would
    /// be attached to the url
    /// [e.g]=>{"a":"yes"}
    /// she.com/getPeople?a=yes
    Map<String, dynamic> queryParameters = const {},
    Object body = const {},
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.put(
        uri,
        queryParameters: queryParameters,
        data: body,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          headers: {
            ..._getAuthHeader,
          },
        ),
      );
      return response.data;
    } on Failure {
      rethrow;
    }
  }

  Future<T> patch<T>(
    /// the api route without the base url
    String uri, {
    ///this are query parameters that would
    /// be attached to the url
    /// [e.g]=>{"a":"yes"}
    /// she.com/getPeople?a=yes
    Map<String, dynamic> queryParameters = const {},
    Object body = const {},
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.patch(
        uri,
        queryParameters: queryParameters,
        data: body,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          headers: {
            ..._getAuthHeader,
          },
        ),
      );
      return response.data;
    } on Failure {
      rethrow;
    }
  }

// ======================================================
//======================== delete ==========================
//=======================================================
  ///get request
  Future<T> delete<T>(
    /// the api route path without the base url
    ///
    String uri, {
    Map<String, dynamic> queryParameters = const {},
    // Options options,
    CancelToken? cancelToken,
  }) async {
    try {
      Response response = await _dio.delete(
        uri,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            ..._getAuthHeader,
          },
        ),
      );

      return response.data;
    } on Failure {
      rethrow;
    }
  }

// ======================================================
//====================== Form data ======================
//=======================================================
  ///Form Data

  Future<dynamic> sendFormData(
    FormDataType requestType, {
    /// route path without baseurl
    required String uri,

    ///this are query parameters that would
    /// be attached to the url
    /// [e.g]=>{"a":"yes"}
    /// she.com/getPeople?a=yes
    Map<String, dynamic> queryParameters = const {},

    /// data to be sent
    /// [must not add file]
    Map<String, dynamic> body = const {},

    /// Files to be sent
    /// [Files only]
    /// for all the images you want to send
    /// the key would act as the parameter sent
    /// to the server
    Map<String, File> images = const {},
    Map<String, List<File>> listImages = const {},
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Map<String, MultipartFile> multipartImages = {};

      await Future.forEach<MapEntry<String, File>>(
        images.entries,
        (item) async {
          final mimeTypeData =
              lookupMimeType(item.value.path, headerBytes: [0xFF, 0xD8])
                  ?.split("/");
          multipartImages[item.key] = await MultipartFile.fromFile(
            item.value.path,
            contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
          );
        },
      );
      Map<String, List<MultipartFile>> multipartListImages = {};
      await Future.forEach<MapEntry<String, List<File>>>(
        listImages.entries,
        (item) async {
          List<MultipartFile> transformedData = [];
          await Future.forEach<File>(
            item.value,
            (element) async {
              final mimeTypeData =
                  lookupMimeType(element.path, headerBytes: [0xFF, 0xD8])
                      ?.split("/");
              transformedData.add(
                await MultipartFile.fromFile(
                  element.path,
                  contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
                ),
              );
            },
          );

          multipartListImages[item.key] = transformedData;
        },
      );

      FormData formData = FormData.fromMap({
        ...body,
        ...multipartImages,
        ...multipartListImages,
      });
      Response response;
      if (FormDataType.patch == requestType) {
        response = await _dio.patch(
          uri,
          queryParameters: queryParameters,
          data: formData,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          options: Options(
            headers: {
              ..._getAuthHeader,
            },
          ),
        );
      } else {
        response = await _dio.post(
          uri,
          queryParameters: queryParameters,
          data: formData,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          options: Options(
            headers: {
              ..._getAuthHeader,
            },
          ),
        );
      }

      return response.data;
    } on Failure {
      rethrow;
    }
  }
}
