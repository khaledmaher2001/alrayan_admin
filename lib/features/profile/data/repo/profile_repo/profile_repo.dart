import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:alrayan_admin/features/profile/data/model/profile_model/profile_model.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepo {
  Future<Either<Failure, ProfileModel>> getProfile();
  Future<Either<Failure, String>> changePassword({required Map<String,dynamic> data});
}

