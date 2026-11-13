import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../local_services/cache_keys.dart';
import '../../roots/app_router.dart';
import 'endpoints.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        // A wrong current password on change-password also answers 401 —
        // that is a form error, not an expired session.
        if (e.response?.statusCode == 401 &&
            !e.requestOptions.path.endsWith(EndPoints.changePassword)) {
          await CacheHelper.removeData(key: "token");
          AppRouter.router.go('/loginView');
        }
        handler.next(e);
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }
  }

  /// Builds the per-request header map. Kept off `_dio.options.headers` so
  /// concurrent requests can't overwrite each other's headers on the shared
  /// [Dio] instance (a multipart upload racing a GET, etc.).
  Map<String, dynamic> _headers({
    required bool sendToken,
    String accept = "application/json",
    String contentType = "application/json",
    String? lang,
    Map<String, dynamic>? extra,
  }) {
    return {
      "Accept": accept,
      "Content-Type": contentType,
      "lang": lang ?? "ar",
      if (sendToken)
        "Authorization": "Bearer ${CacheKeysManger.tokenStatus()}",
      ...?extra,
    };
  }

  Future<Response> postData({
    required String endPoint,
    bool sendToken = false,
    dynamic data,
    Map<String,dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    var response = await _dio.post(
      "${EndPoints.baseUrl}$endPoint",
      data: data,
      queryParameters: query,
      cancelToken: cancelToken,
      options: Options(headers: _headers(sendToken: sendToken)),
    );
    return response;
  }

  Future<Response> get({
    required String endPoint,
    bool sendToken = false,
    dynamic data,
    dynamic query,
    String? baseUrl,
    CancelToken? cancelToken,
  }) async {
    var response = await _dio.get(
      '${baseUrl ?? EndPoints.baseUrl}$endPoint',
      queryParameters: query,
      data: data,
      cancelToken: cancelToken,
      options: Options(headers: _headers(sendToken: sendToken)),
    );
    return response;
  }

  Future<Response> putData({
    required String endPoint,
    dynamic data,
    dynamic query,
    CancelToken? cancelToken,
  }) async {
    var response = await _dio.put(
      '${EndPoints.baseUrl}$endPoint',
      data: data,
      queryParameters: query,
      cancelToken: cancelToken,
      options: Options(headers: _headers(sendToken: true, accept: "*/*")),
    );
    return response;
  }

  Future<Response> postDataWithImage({required String endPoint,
    bool sendToken = true,
    FormData? data,
    String? baseUrl,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress}) async {
    var response = await _dio.post(
      "${baseUrl ?? EndPoints.baseUrl}$endPoint",
      data: data,
      queryParameters: query,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        headers: _headers(
          sendToken: sendToken,
          accept: "*/*",
          contentType: "multipart/form-data",
          lang: CacheKeysManger.getUserLanguageFromCache(),
        ),
      ),
    );
    return response;
  }

  Future<Response> patchDataWithImage({required String endPoint,
    bool sendToken = true,
    FormData? data,
    String? baseUrl,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress}) async {
    var response = await _dio.patch(
      "${baseUrl ?? EndPoints.baseUrl}$endPoint",
      data: data,
      queryParameters: query,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      options: Options(
        headers: _headers(
          sendToken: sendToken,
          accept: "*/*",
          contentType: "multipart/form-data",
          lang: CacheKeysManger.getUserLanguageFromCache(),
        ),
      ),
    );
    return response;
  }

  Future<Response> patchData({
    required String endPoint,
    bool sendToken = true,
    String? baseUrl,
    dynamic data,
    dynamic query,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress
  }) async {
    return await _dio.patch(
      '${baseUrl ?? EndPoints.baseUrl}$endPoint',
      data: data,
      queryParameters: query,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      options: Options(
        headers: _headers(sendToken: sendToken, extra: headers),
      ),
    );
  }


  Future<Response> deleteData({
    required String endPoint,
    bool sendToken = false,
    dynamic data,
    Map<String,dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    var response = await _dio.delete(
      "${EndPoints.baseUrl}$endPoint",
      data: data,
      queryParameters: query,
      cancelToken: cancelToken,
      options: Options(headers: _headers(sendToken: sendToken)),
    );
    return response;
  }

}
