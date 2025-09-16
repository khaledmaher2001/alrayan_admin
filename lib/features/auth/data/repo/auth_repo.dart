import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';
import '../models/settings_model.dart';

abstract class AuthRepo {
  Future<Either<Failure, LoginModel>> userLogin(
      {required String email, required String password});
  Future<Either<Failure, SettingsModel>> getSettings();
  Future<Either<Failure,RegisterModel>>userRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
  });
  Future<Either<Failure, bool>> verifyOtp({required Map<String, dynamic> data});
  Future<Either<Failure, String>> sendOtp({required String email});
  Future<Either<Failure, String>> resetPassword(
      {required Map<String, dynamic> data});
  Future<Either<Failure, String>> forgetPassword({required String email});

}
