import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/coupons_model.dart';

abstract class CouponsRepo{
  Future<Either<Failure,String>> createCoupon({required Map<String,dynamic> data});
  Future<Either<Failure, CouponsModel>> getCoupons({required int page});
  Future<Either<Failure, String>> deleteCoupon({required int couponId});

}