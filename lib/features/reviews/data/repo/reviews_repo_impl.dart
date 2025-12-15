import 'package:alrayan_admin/features/reviews/data/repo/reviews_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';
import '../models/reviews_model.dart';
import '../models/reviews_summery_model.dart';

class ReviewRepoImpl implements ReviewsRepo {
  final ApiService apiService;

  ReviewRepoImpl(this.apiService);

  @override
  Future<Either<Failure, ReviewsSummaryModel>> getReviewsSummery() async {
    try {
      var response = await apiService.get(endPoint: EndPoints.reviewsSummery,sendToken: true);
      var result = ReviewsSummaryModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, ReviewsModel>> getReviews({required int page}) async {
    try {
      var response = await apiService.get(endPoint: EndPoints.reviews, query: {
        "page": page,
      },sendToken: true);
      var result = ReviewsModel.fromJson(response.data);
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
