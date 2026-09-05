import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';
import '../models/all_users_model.dart';
import '../models/customer_lifetime_value_model.dart';
import '../models/user_detail_model.dart';
import 'all_users_repo.dart';

class AllUsersRepoImpl implements AllUsersRepo {
  final ApiService? apiService;

  AllUsersRepoImpl(this.apiService);

  @override
  Future<Either<Failure, AllUsersModel>> getAllUsers({required Map<String, dynamic> data}) async {
    try {
      var response = await apiService!.get(endPoint: EndPoints.users, query: data, sendToken: true);
      return right(AllUsersModel.fromJson(response.data));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserDetailModel>> getUserById(int id) async {
    try {
      var response = await apiService!.get(endPoint: EndPoints.userById(id), sendToken: true);
      return right(UserDetailModel.fromJson(response.data['data']));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerLifetimeValueModel>> getCustomerLifetimeValue(int id) async {
    try {
      var response = await apiService!.get(endPoint: EndPoints.customerLifetimeValue(id), sendToken: true);
      return right(CustomerLifetimeValueModel.fromJson(response.data));
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(int id) async {
    try {
      await apiService!.deleteData(endPoint: EndPoints.userById(id), sendToken: true);
      return right(true);
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(e.toString()));
    }
  }
}
