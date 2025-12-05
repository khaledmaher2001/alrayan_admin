import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/errors/failure.dart';

import '../../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../../core/utils/services/remote_services/endpoints.dart';
import '../models/lucky_wheel_model.dart';
import 'luck_wheel_repo.dart';

class LuckyWheelRepoImpl implements LuckyWheelRepo {
  final ApiService? apiService;

  LuckyWheelRepoImpl(this.apiService);

  @override
  Future<Either<Failure, String>> createLuckyItem({required Map<String,dynamic> data}) async {
    try {
      var response = await apiService!.postData(endPoint: EndPoints.luckyWheel, data: data,sendToken: true);
      return right(response.data["message"]);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, LuckyWheelModel>> getLuckyWheelItems() async {
    try {
      var response = await apiService!.get(endPoint: EndPoints.luckyWheel, sendToken: true,);
      var result = LuckyWheelModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");

      if (e is DioException) {
        print(e.response);

        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, String>> deleteLuckyItem({required int itemId}) async {
    try {
      var response = await apiService!.deleteData(
        endPoint: "${EndPoints.luckyWheel}/$itemId",
        sendToken: true,
      );
      return right(response.data["message"]);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

}
