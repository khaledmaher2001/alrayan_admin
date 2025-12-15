import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../../../home/data/models/home_statistics_model.dart';


abstract class TopUsersRepo {
  Future<Either<Failure, List<TopCustomers>>> getTopUsers();

}
