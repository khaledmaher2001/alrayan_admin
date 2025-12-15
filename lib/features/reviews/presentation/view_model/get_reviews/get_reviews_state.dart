part of 'get_reviews_cubit.dart';

abstract class GetReviewsState {}

class GetReviewsInitial extends GetReviewsState {}

class GetReviewsLoadingState extends GetReviewsState {}

class GetReviewsSuccessState extends GetReviewsState {
  final ReviewsModel reviewsModel;

  GetReviewsSuccessState({required this.reviewsModel});
}

class GetReviewsErrorState extends GetReviewsState {
  final String error;

  GetReviewsErrorState(this.error);
}
