
import 'package:alrayan_admin/features/auth/data/models/update_settings_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';
import '../models/settings_model.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final ApiService apiService;

  AuthRepoImpl(this.apiService);

  @override
  Future<Either<Failure, LoginModel>> userLogin({
    required String email,
    required String password,
  }) async {
    try {
      String subscriptionId =
      OneSignal.User.pushSubscription.id.toString();
      final response = await apiService.postData(
        endPoint: EndPoints.login,
        data: {
          'identifier': email,
          'password': password,
          'playerId': subscriptionId,
        },
      );
      print(response.data);
      if (response.statusCode == 200) {
        final loginResponse = LoginModel.fromJson(response.data);
        return Right(loginResponse); // Success case
      } else {
        return Left(
            ServerFailure('Unexpected status code: ${response.statusCode}'));
      }
    } catch (e) {
      print("FFFFFFFFFFFFFFF:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(ServerFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, RegisterModel>> userRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      String subscriptionId =
      OneSignal.User.pushSubscription.id.toString();
      final response = await apiService.postData(
        endPoint: EndPoints.register,
        data: {
          'fullName': name,
          'email': email,
          'password': password,
          "phoneNumber": phone,
          "playerId":subscriptionId
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final registerResponse = RegisterModel.fromJson(response.data);
        return Right(registerResponse);
      } else {

        return Left(ServerFailure(
            'Unexpected status code: ${response.statusCode}, Message: ${response.statusMessage}'));
      }
    } catch (e) {
      print("GGGGGGGGGGGGGGGGGGGG:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, SettingsModel>> getSettings() async {
    try {
      var response = await apiService.get(endPoint: EndPoints.getSettings);
      var result = SettingsModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      print("EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE${e.toString()}");
      if (e is DioException) {
        print("EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE${e.response}");
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, String>> sendOtp({required String email}) async {
    try {
      var response = await apiService.postData(endPoint: EndPoints.sendOTP, data: {
        "email": email,
      });
      print("------------- otp is ------------------");
      print(response.data["success"]);
      return right(response.data["message"]);
    } catch (e) {
      if (e is DioException) {
        print("------------------- Error From SendOtp --------------------");
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, bool>> verifyOtp({required Map<String, dynamic> data}) async {
    try {
      var response = await apiService.postData(endPoint: EndPoints.verifyOTP, data: data);
      return right(response.data["success"]);
    } catch (e) {
      if (e is DioException) {
        print("DDDDDDDDDDDDDDDDDD: ${e.response}");
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, String>> resetPassword(
      {required Map<String, dynamic> data}) async {
    try {
      var response = await apiService.postData(
        endPoint: EndPoints.resetPassword,
        data: data,
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
  @override
  Future<Either<Failure, String>> forgetPassword(
      {required String email}) async {
    try {
      var response = await apiService.postData(
        endPoint: EndPoints.forgetPassword,
        data: {"email": email},
      );
      return right(response.data["message"]);
    } catch (e) {
      print("GGGGGGGGGGGGGGGGGGGGGGGG");
      print(e.toString());
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, UpdateSettingsModel>> updateSettings({required Map<String,dynamic> data}) async{
    try {
      var response = await apiService.putData(
        endPoint: EndPoints.updateSettings,
        data: data,
      );
      var result = UpdateSettingsModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

}
