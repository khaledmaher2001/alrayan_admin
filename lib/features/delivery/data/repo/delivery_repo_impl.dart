import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';
import '../models/delivery_account_model.dart';
import '../models/delivery_statistics_model.dart';
import '../models/delivery_transaction_model.dart';
import '../models/delivery_wallet_model.dart';
import '../models/release_log_model.dart';
import '../models/remittance_model.dart';
import 'delivery_repo.dart';

class DeliveryRepoImpl implements DeliveryRepo {
  final ApiService? apiService;

  DeliveryRepoImpl(this.apiService);

  /// Every other endpoint in this app wraps its payload as
  /// `{success, message, data: {...}}`. Swagger doesn't document the
  /// response envelope for the create/update delivery-profile endpoints, so
  /// this unwraps defensively: prefer `data` if it's a map, otherwise fall
  /// back to the raw body — never invents fields that aren't there.
  Map<String, dynamic> _unwrap(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body['data'] is Map<String, dynamic>) {
        return body['data'];
      }
      return body;
    }
    return {};
  }

  @override
  Future<Either<Failure, DeliveryAccountsModel>> getDeliveryAccounts({
    required Map<String, dynamic> data,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await apiService!.get(
        endPoint: EndPoints.deliveryAccounts,
        query: data,
        sendToken: true,
        cancelToken: cancelToken,
      );
      return right(DeliveryAccountsModel.fromJson(response.data));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryAccount?>> findDeliveryAccount(int userId) async {
    const pageSize = 100; // backend max
    const maxPages = 20;
    for (var page = 1; page <= maxPages; page++) {
      final result = await getDeliveryAccounts(data: {'page': page, 'limit': pageSize});
      if (result.isLeft()) {
        return left(result.fold((failure) => failure, (_) => ServerFailure('')));
      }
      final data = result.getOrElse(() => DeliveryAccountsModel.fromJson(const {})).data;
      final items = data?.items ?? const <DeliveryAccount>[];
      for (final account in items) {
        if (account.userId == userId) return right(account);
      }
      final totalPages = data?.metadata?.totalPages;
      if (items.length < pageSize || (totalPages != null && page >= totalPages)) break;
    }
    return right(null);
  }

  @override
  Future<Either<Failure, DeliveryStatisticsModel>> getDeliveryStatistics() async {
    try {
      final response = await apiService!.get(
        endPoint: EndPoints.deliveryStatistics,
        sendToken: true,
      );
      return right(DeliveryStatisticsModel.fromJson(response.data));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryAccount>> createDeliveryAccount({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiService!.postData(
        endPoint: EndPoints.deliveryAccounts,
        data: data,
        sendToken: true,
      );
      return right(DeliveryAccount.fromJson(_unwrap(response.data)));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryAccount>> updateDeliveryProfile({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiService!.patchData(
        endPoint: EndPoints.deliveryAccountProfile(userId),
        data: data,
        sendToken: true,
      );
      return right(DeliveryAccount.fromJson(_unwrap(response.data)));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDeliveryAccount(int userId) async {
    try {
      await apiService!.deleteData(
        endPoint: EndPoints.userById(userId),
        sendToken: true,
      );
      return right(true);
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryWalletModel>> getDeliveryWallet(
    int userId,
  ) async {
    try {
      final response = await apiService!.get(
        endPoint: EndPoints.deliveryAccountWallet(userId),
        sendToken: true,
      );
      final body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      return right(DeliveryWalletModel.fromJson(body));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryTransactionsModel>> getDeliveryTransactions({
    required int userId,
    required Map<String, dynamic> data,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await apiService!.get(
        endPoint: EndPoints.deliveryAccountTransactions(userId),
        query: data,
        sendToken: true,
        cancelToken: cancelToken,
      );
      return right(DeliveryTransactionsModel.fromJson(response.data));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReleaseLogsModel>> getReleaseLogs({
    required Map<String, dynamic> data,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await apiService!.get(
        endPoint: EndPoints.deliveryReleaseLogs,
        query: data,
        sendToken: true,
        cancelToken: cancelToken,
      );
      return right(ReleaseLogsModel.fromJson(response.data));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RemittancesModel>> getRemittances({
    required Map<String, dynamic> data,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await apiService!.get(
        endPoint: EndPoints.deliveryRemittances,
        query: data,
        sendToken: true,
        cancelToken: cancelToken,
      );
      return right(RemittancesModel.fromJson(response.data));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> approveRemittance(int id) async {
    try {
      final response = await apiService!.patchData(
        endPoint: EndPoints.deliveryRemittanceApprove(id),
        sendToken: true,
      );
      return right(response.data["message"]);
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> rejectRemittance(int id) async {
    try {
      final response = await apiService!.patchData(
        endPoint: EndPoints.deliveryRemittanceReject(id),
        sendToken: true,
      );
      return right(response.data["message"]);
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }
}
