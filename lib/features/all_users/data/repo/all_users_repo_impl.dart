import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';
import '../models/all_users_model.dart';
import 'all_users_repo.dart';

class AllUsersRepoImpl implements AllUsersRepo {
  final ApiService? apiService;

  AllUsersRepoImpl(this.apiService);

  @override
  Future<Either<Failure, AllUsersModel>> getAllUsers({required Map<String, dynamic> data}) async {
    try {
      var response = await apiService!.get(endPoint: EndPoints.users, query: data, sendToken: true);
      var result = AllUsersModel.fromJson(response.data);
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
