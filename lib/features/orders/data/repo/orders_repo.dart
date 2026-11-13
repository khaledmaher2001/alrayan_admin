import 'package:dio/dio.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class OrdersRepo {
  /// [cancelToken] lets a caller abort an in-flight list request when it
  /// starts a newer one (e.g. switching status filter) so a slow stale
  /// response can't land on top of the current list.
  Future<Either<Failure, OrdersModel>> getOrders({
    required Map<String, dynamic> data,
    CancelToken? cancelToken,
  });
  Future<Either<Failure, Items>> getOrderDetails({required int orderId});
  Future<Either<Failure, String>> changeOrderStatus({
    required int orderId,
    required Map<String, dynamic> data,
  });

  /// `PUT /orders/:id/cancel`. [data] carries the documented cancel body
  /// (e.g. `{"reason": "..."}`) when the caller has one; older callers that
  /// don't send a reason keep working unchanged.
  Future<Either<Failure, String>> cancelOrder({
    required int orderId,
    Map<String, dynamic>? data,
  });

  /// `PATCH /orders/:id/reopen` — makes an `awaiting_customer` order
  /// available to couriers again. Returns the backend message.
  Future<Either<Failure, String>> reopenOrder({required int orderId});
}
