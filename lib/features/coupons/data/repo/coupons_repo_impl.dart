import 'package:alrayan_admin/features/coupons/data/repo/coupons_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/errors/failure.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';

class CouponsRepoImpl implements CouponsRepo {
  final ApiService? apiService;

  CouponsRepoImpl(this.apiService);

  @override
  Future<Either<Failure, String>> createCoupon({required Map<String,dynamic> data}) async {
    try {
      var response = await apiService!.postData(endPoint: EndPoints.coupons, data: data,sendToken: true);
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
}
