import 'package:alrayan_admin/features/zones/data/models/zones_model.dart';
import 'package:alrayan_admin/features/zones/data/repo/zones_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';

class ZonesRepoImpl implements ZonesRepo {
  final ApiService? apiService;

  ZonesRepoImpl(this.apiService);

  @override
  Future<Either<Failure, ZonesModel>> getZones() async {
    try {
      var response = await apiService!.get(endPoint: EndPoints.zones, sendToken: true);
      var result = ZonesModel.fromJson(response.data);
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

  @override
  Future<Either<Failure,String>> addZone({required Map<String,dynamic> data}) async {
    try {
      var response = await apiService!.postData(
        endPoint: EndPoints.zones,
        data: data,
          sendToken: true

      );
      return right(response.data["message"]);
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) {
        debugPrint(e.response.toString());
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  } @override
  Future<Either<Failure,String>> editZone({required int zoneId,required Map<String,dynamic> data}) async {
    try {
      var response = await apiService!.patchData(
        endPoint: "${EndPoints.zones}/$zoneId",
        data: data,
        sendToken: true
      );
      return right(response.data["message"]);
    } catch (e) {
      debugPrint(e.toString());
      if (e is DioException) {
        debugPrint(e.response.toString());
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }@override
  Future<Either<Failure,String>> deleteZone({required int zoneId}) async {
    try {
      var response = await apiService!.deleteData(
        endPoint: "${EndPoints.zones}/$zoneId",
        sendToken: true
      );
      return right(response.data["message"]);
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
