import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';

class OrdersRepoImpl implements OrdersRepo {
  final ApiService? apiService;

  OrdersRepoImpl(this.apiService);

  @override
  Future<Either<Failure, OrdersModel>> getOrders({required Map<String, dynamic> data}) async {
    try {
      var response = await apiService!.get(endPoint: EndPoints.orders, query: data, sendToken: true);
      var result = OrdersModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) {
        debugPrint(e.response.toString());
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, Items>> getOrderDetails({required int orderId}) async {
    try {
      var response = await apiService!.get(endPoint: "${EndPoints.orders}/$orderId",sendToken: true);
      var result = Items.fromJson(response.data["data"]);
      return right(result);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> changeOrderStatus({required int orderId, required Map<String, dynamic> data}) async {
    try {
      var response = await apiService!.patchData(
        endPoint: "${EndPoints.orders}/$orderId",
        data: data,
      );
      return right(response.data["message"]);
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) {
        debugPrint(e.response.toString());
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> cancelOrder({required int orderId}) async {
    try {
      var response = await apiService!.putData(
        endPoint: "${EndPoints.orders}/$orderId/cancel",
      );
      return right(response.data["message"]);
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) {
        debugPrint(e.response.toString());
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
