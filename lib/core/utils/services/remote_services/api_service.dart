import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../local_services/cache_keys.dart';
import 'endpoints.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    // Add PrettyDioLogger interceptor only in debug mode
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

  Future<Response> postData({
    required String endPoint,
    bool sendToken = false,
    dynamic data,
    Map<String,dynamic>? query,
  }) async {
    _dio.options.headers = {
      "Accept":"application/json",
      "Content-Type": "application/json",
      "lang":"ar",
      if (sendToken)
        "Authorization": "Bearer ${CacheKeysManger.tokenStatus()}"
    };
    var response = await _dio.post(
      "${EndPoints.baseUrl}$endPoint",
      data: data,
      queryParameters: query,
    );
    return response;
  }

  Future<Response> get({
    required String endPoint,
    bool sendToken = false,
    dynamic data,
   dynamic query,
  }) async {
    _dio.options.headers = {
      "Content-Type": "application/json",
      "lang":"ar",
      if (sendToken)
        "Authorization": "Bearer ${CacheKeysManger.tokenStatus()}"
    };
    var response = await _dio.get(
      '${EndPoints.baseUrl}$endPoint',
      queryParameters: query,
      data: data,
    );
    return response;
  }
  Future<Response> putData({
    required String endPoint,
    dynamic data,
    dynamic query,

  }) async {
    _dio.options.headers = {
      "accept":"*/*",
      "Content-Type": "application/json",
      "Authorization":"Bearer ${CacheKeysManger.tokenStatus()}",
      "lang":"ar",
    };
    var response = await _dio.put(
      '${EndPoints.baseUrl}$endPoint',
      data: data,
      queryParameters: query
    );
    return response;
  }
  Future<Response> postDataWithImage({required String endPoint,
    bool sendToken = true,
    FormData? data,
    String? baseUrl,
    Map<String, dynamic>? query,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress}) async {
    _dio.options.headers = {
      "accept":"*/*",
      "Content-Type": "multipart/form-data",
      "lang":CacheKeysManger.getUserLanguageFromCache(),
      if (sendToken)
        "Authorization": "Bearer ${CacheKeysManger.tokenStatus()}"
    };
    var response = await _dio.post(
      "${EndPoints.baseUrl}$endPoint",
      data: data,
      queryParameters: query,
    );
    return response;
  }
  Future<Response> patchData({
    required String endPoint,
    bool sendToken = true,
    String? baseUrl,
    dynamic data,
    dynamic query,
    Map<String, dynamic>? headers, void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress
  }) async {
    _dio.options.headers = {
      "Accept":"application/json",
      "Content-Type": "application/json",
      "lang":"ar",
      if (sendToken)
        "Authorization": "Bearer ${CacheKeysManger.tokenStatus()}"
    };
    return await _dio.patch(
      '${baseUrl ?? EndPoints.baseUrl}$endPoint',
      data: data,
      queryParameters: query,
    );
  }


  Future<Response> deleteData({
    required String endPoint,
    bool sendToken = false,
    dynamic data,
    Map<String,dynamic>? query,
  }) async {
    _dio.options.headers = {
      "Accept":"application/json",
      "Content-Type": "application/json",
      "lang":"ar",
      if (sendToken)
        "Authorization": "Bearer ${CacheKeysManger.tokenStatus()}"
    };
    var response = await _dio.delete(
      "${EndPoints.baseUrl}$endPoint",
      data: data,
      queryParameters: query,
    );
    return response;
  }

}
