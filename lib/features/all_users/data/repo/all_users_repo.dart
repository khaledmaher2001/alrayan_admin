import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/all_users_model.dart';
import '../models/customer_lifetime_value_model.dart';
import '../models/user_detail_model.dart';

abstract class AllUsersRepo {
  Future<Either<Failure, AllUsersModel>> getAllUsers({
    required Map<String, dynamic> data,
    CancelToken? cancelToken,
  });
  Future<Either<Failure, UserDetailModel>> getUserById(int id);
  Future<Either<Failure, CustomerLifetimeValueModel>> getCustomerLifetimeValue(int id);
  Future<Either<Failure, bool>> deleteUser(int id);
}
