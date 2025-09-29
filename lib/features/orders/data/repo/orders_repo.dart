import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class OrdersRepo{
  Future<Either<Failure,OrdersModel>> getOrders({required Map<String,dynamic> data});
  Future<Either<Failure,String>> changeOrderStatus({required int orderId,required Map<String,dynamic> data});
  Future<Either<Failure,String>> cancelOrder({required int orderId});

}