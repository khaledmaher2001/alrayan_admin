import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/home/data/models/inventory_analytics_model.dart';
import 'package:alrayan_admin/features/home/data/models/item_analytics_model.dart';
import 'package:alrayan_admin/features/home/data/models/low_stock_config_model.dart';
import 'package:alrayan_admin/features/home/data/models/low_stock_product_model.dart';
import 'package:alrayan_admin/features/home/data/models/sales_report_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';
import 'home_repo.dart';

class HomeRepoImpl implements HomeRepo {
  final ApiService? apiService;

  HomeRepoImpl(this.apiService);

  @override
  Future<Either<Failure, HomeStatisticsModel>> getHomeStatistics({
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await apiService!.get(
        endPoint: EndPoints.homeStatistics,
        sendToken: true,
        cancelToken: cancelToken,
      );
      var result = HomeStatisticsModel.fromJson(response.data);
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
  Future<Either<Failure, InventoryAnalyticsResponseModel>>
  getInventoryAnalytics({
    int page = 1,
    int limit = 20,
    String? search,
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await apiService!.get(
        endPoint: EndPoints.inventoryAnalytics,
        sendToken: true,
        cancelToken: cancelToken,
        query: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final result = InventoryAnalyticsResponseModel.fromJson(response.data);
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
  Future<Either<Failure, ItemAnalyticsModel>> getItemAnalytics({
    required int productId,
    String? groupBy,
    String? startDate,
    String? endDate,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await apiService!.get(
        endPoint: EndPoints.itemAnalytics(productId),
        sendToken: true,
        cancelToken: cancelToken,
        query: {
          // `groupBy` and an explicit date range are mutually exclusive on the
          // API — only forward whichever the caller supplied.
          if (groupBy != null && groupBy.isNotEmpty) 'groupBy': groupBy,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );
      return right(ItemAnalyticsModel.fromJson(response.data));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) {
        debugPrint(e.response.toString());
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LowStockProductsResponseModel>> getLowStockProducts({
    int? threshold,
    int page = 1,
    int limit = 20,
    String? search,
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await apiService!.get(
        endPoint: EndPoints.lowStockProducts,
        sendToken: true,
        cancelToken: cancelToken,
        query: {
          // Omitted so the server falls back to the configured low-stock
          // threshold instead of a hardcoded default.
          if (threshold != null) 'threshold': threshold,
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final result = LowStockProductsResponseModel.fromJson(response.data);
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
  Future<Either<Failure, LowStockConfigModel>> getLowStockConfig() async {
    try {
      var response = await apiService!.get(
        endPoint: EndPoints.lowStockConfig,
        sendToken: true,
      );
      final result = LowStockConfigModel.fromJson(response.data);
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
  Future<Either<Failure, LowStockConfigModel>> updateLowStockConfig({
    required int threshold,
  }) async {
    try {
      var response = await apiService!.patchData(
        endPoint: EndPoints.lowStockConfig,
        sendToken: true,
        data: {'threshold': threshold},
      );
      // Some responses come back without a usable body; fall back to the
      // threshold we just sent so the UI still reflects the update.
      final result = response.data is Map<String, dynamic>
          ? LowStockConfigModel.fromJson(response.data)
          : LowStockConfigModel(threshold: threshold);
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
  Future<Either<Failure, SalesReportModel>> getSalesReport({
    required String startDate,
    required String endDate,
    String type = '',
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await apiService!.get(
        endPoint: EndPoints.salesReport,
        sendToken: true,
        cancelToken: cancelToken,
        query: {
          'startDate': startDate,
          'endDate': endDate,
          'type': type,
        },
      );
      var result = SalesReportModel.fromJson(response.data);
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

}
