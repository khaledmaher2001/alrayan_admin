import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
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
  Future<Either<Failure, HomeStatisticsModel>> getHomeStatistics() async {
    try {
      var response = await apiService!.get(endPoint: EndPoints.homeStatistics, sendToken: true);
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

}
