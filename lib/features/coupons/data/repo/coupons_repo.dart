import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/coupons_model.dart';

abstract class CouponsRepo{
  Future<Either<Failure,String>> createCoupon({required Map<String,dynamic> data});
  Future<Either<Failure, CouponsModel>> getCoupons({
    required int page,
    CancelToken? cancelToken,
  });
  Future<Either<Failure, String>> deleteCoupon({required int couponId});
  Future<Either<Failure, String>> updateCoupon({required int couponId, required Map<String,dynamic> data});

}