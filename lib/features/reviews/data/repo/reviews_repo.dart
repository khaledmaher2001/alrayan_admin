import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/reviews_model.dart';
import '../models/reviews_summery_model.dart';


abstract class ReviewsRepo {
  Future<Either<Failure, ReviewsSummaryModel>> getReviewsSummery();
  Future<Either<Failure, ReviewsModel>> getReviews({required int page});

}
