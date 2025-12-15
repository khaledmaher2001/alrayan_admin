part of 'get_reviews_summery_cubit.dart';

abstract class GetReviewsSummeryState {}

class GetReviewsSummeryInitial extends GetReviewsSummeryState {}

class GetReviewsSummeryLoadingState extends GetReviewsSummeryState {}

class GetReviewsSummerySuccessState extends GetReviewsSummeryState {
  final ReviewsSummaryModel summeryModel;

  GetReviewsSummerySuccessState({required this.summeryModel});
}

class GetReviewsSummeryErrorState extends GetReviewsSummeryState {
  final String error;

  GetReviewsSummeryErrorState(this.error);
}
