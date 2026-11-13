import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';

/// One recorded return (goods received back) and its refund.
class OrderReturnModel {
  final int id;
  final double refundAmount;
  final String refundStatus; // pending | completed | failed | not_required
  final String? refundFailureReason;
  final String? createdAt;
  final List<({int orderItemId, int quantity, bool restock})> items;

  OrderReturnModel.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        refundAmount = double.tryParse('${j['refundAmount']}') ?? 0,
        refundStatus = j['refundStatus'] ?? 'pending',
        refundFailureReason = j['refundFailureReason'],
        createdAt = j['createdAt'],
        items = ((j['items'] as List?) ?? [])
            .map((i) => (orderItemId: i['orderItemId'] as int, quantity: i['quantity'] as int, restock: i['restock'] != false))
            .toList();
}

/// Cash collection, returns and refunds (backend 2026-10-09). The amounts
/// shown in the app always come from these server records.
class OrderFinanceRepo {
  final ApiService apiService;
  OrderFinanceRepo(this.apiService);

  Future<Either<Failure, T>> _run<T>(Future<T> Function() f) async {
    try {
      return right(await f());
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<OrderReturnModel>>> getReturns(int orderId) => _run(() async {
        final r = await apiService.get(endPoint: "${EndPoints.orders}/$orderId/finance", sendToken: true);
        final list = (r.data['data']?['returns'] as List?) ?? [];
        return list.map((e) => OrderReturnModel.fromJson(e)).toList();
      });

  /// Records cash actually received (default: everything outstanding).
  Future<Either<Failure, String>> collect(int orderId, {double? amount, required String key}) => _run(() async {
        final r = await apiService.postData(
          endPoint: "${EndPoints.orders}/$orderId/payment/collect",
          sendToken: true,
          data: {if (amount != null) 'amount': amount, 'idempotencyKey': key},
        );
        return '${r.data['message'] ?? 'تم تسجيل التحصيل'}';
      });

  /// Goods received back: [{orderItemId, quantity, restock}].
  Future<Either<Failure, String>> createReturn(int orderId,
          {required List<Map<String, dynamic>> items, required bool refundCash, bool includeDeliveryFee = false, String? note, required String key}) =>
      _run(() async {
        final r = await apiService.postData(
          endPoint: "${EndPoints.orders}/$orderId/returns",
          sendToken: true,
          data: {
            'items': items,
            'refundMethod': refundCash ? 'cash' : 'none',
            if (includeDeliveryFee) 'includeDeliveryFee': true,
            if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
            'idempotencyKey': key,
          },
        );
        return '${r.data['message'] ?? 'تم تسجيل المرتجع'}';
      });

  /// outcome: completed (money handed back) | failed (with a reason).
  Future<Either<Failure, String>> settleRefund(int returnId, {required bool completed, String? reason, String? reference}) => _run(() async {
        final r = await apiService.patchData(
          endPoint: "${EndPoints.orders}/returns/$returnId/refund",
          data: {
            'outcome': completed ? 'completed' : 'failed',
            if (reason != null) 'reason': reason,
            if (reference != null && reference.trim().isNotEmpty) 'reference': reference.trim(),
          },
        );
        return '${r.data['message'] ?? 'تم التحديث'}';
      });
}
