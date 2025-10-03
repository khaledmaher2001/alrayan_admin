import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class HomeRepo{
  Future<Either<Failure,HomeStatisticsModel>> getHomeStatistics();

}