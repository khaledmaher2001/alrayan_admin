import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/reviews_model.dart';
import '../../../data/repo/reviews_repo.dart';
part 'get_reviews_state.dart';

class GetReviewsCubit extends Cubit<GetReviewsState> {
  GetReviewsCubit(this.repo) : super(GetReviewsInitial());

  ReviewsRepo repo;

  ReviewsModel? reviewsModel;
  List<Items> allReviewsList = [];

  Future<void> getReviews({
    required int page,
    bool withLoading = true,
  }) async {
    if (withLoading) {
      emit(GetReviewsLoadingState());
      page = 1;
      allReviewsList.clear();
    }
    final result = await repo.getReviews(
      page: page,
    );
    result.fold(
      (failure) {
        emit(GetReviewsErrorState(failure.errMessage));
      },
      (data) {
        reviewsModel = data;
        allReviewsList = allReviewsList + data.data!.items!;
        emit(GetReviewsSuccessState(reviewsModel: data));
      },
    );
  }
}
