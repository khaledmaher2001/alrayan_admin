import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/all_users_model.dart';

abstract class AllUsersRepo{
  Future<Either<Failure,AllUsersModel>> getAllUsers({required Map<String,dynamic> data});

}