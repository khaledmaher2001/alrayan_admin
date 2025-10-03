import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/api_service.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/endpoints.dart';
import 'package:alrayan_admin/features/profile/data/model/profile_model/profile_model.dart';
import 'package:alrayan_admin/features/profile/data/repo/profile_repo/profile_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ApiService apiService;

  ProfileRepoImpl(this.apiService);

  @override
  Future<Either<Failure, ProfileModel>> getProfile() async {
    try {
      final response = await apiService.get(endPoint: EndPoints.profile, sendToken: true);
      final dynamic profileData = response.data;
      final ProfileModel profile = ProfileModel.fromJson(profileData);
      return Right(profile);
    } catch (e) {
      print(("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR:${e.toString()}"));
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> changePassword({required Map<String, dynamic> data}) async {
    try {

     await apiService.postData(
        endPoint: EndPoints.changePassword,
        data: data,
        sendToken: true,
      );
      return Right("تم تغيير الرقم السرى بنجاح");
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
