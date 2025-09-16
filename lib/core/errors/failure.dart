import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/shared_widgets/toast.dart';

abstract class Failure {
  final String errMessage;

  Failure(this.errMessage);
}

class ServerFailure extends Failure {
  ServerFailure(super.errMessage);

  factory ServerFailure.fromDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionError:
        return ServerFailure("noInternet");

      case DioExceptionType.connectionTimeout:
        return ServerFailure("connectionTimeOut");
      case DioExceptionType.sendTimeout:
        return ServerFailure("sendTimeOut");
      case DioExceptionType.receiveTimeout:
        return ServerFailure("receiveTimeOut");
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            dioException.response!.statusCode!, dioException.response!.data);
      case DioExceptionType.cancel:
        return ServerFailure("requestCanceled");
      case DioExceptionType.unknown:
        if (dioException.error!.toString().contains("SocketException")) {
          return ServerFailure("noInternet");
        } else {
          return ServerFailure("unexpectedError");
        }

      default:
        return ServerFailure("Something went Error Try Again");
    }
  }

  factory ServerFailure.fromResponse(int statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403|| statusCode == 422||statusCode==409||statusCode==404) {
      return ServerFailure(response["message"].toString());
    } else if (statusCode == 500) {
      return ServerFailure("internalServerError");
    } else if (statusCode == 404) {
      return ServerFailure("requestNotFound");
    } else {
      return ServerFailure("Something went Error Try Again");
    }
  }
}
