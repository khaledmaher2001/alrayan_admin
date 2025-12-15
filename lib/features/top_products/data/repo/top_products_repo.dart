import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../../../home/data/models/home_statistics_model.dart';


abstract class TopProductsRepo {
  Future<Either<Failure, List<TopSellingProducts>>> getTopProducts();

}
