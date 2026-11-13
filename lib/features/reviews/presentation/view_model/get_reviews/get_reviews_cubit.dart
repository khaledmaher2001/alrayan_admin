import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';
import '../../../data/models/reviews_model.dart';
import '../../../data/repo/reviews_repo.dart';
part 'get_reviews_state.dart';

class GetReviewsCubit extends Cubit<GetReviewsState> with RequestGuardMixin {
  GetReviewsCubit(this.repo) : super(GetReviewsInitial());

  ReviewsRepo repo;

  ReviewsModel? reviewsModel;
  List<Items> allReviewsList = [];
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  Future<void> getReviews({int page = 1, bool withLoading = true}) async {
    final reqId = beginRequest();
    if (withLoading) {
      this.page = 1;
      hasMore = true;
      allReviewsList.clear();
      emit(GetReviewsLoadingState());
    } else {
      this.page = page;
    }

    final result = await repo.getReviews(
      page: this.page,
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;

    result.fold(
      (failure) {
        emit(GetReviewsErrorState(failure.errMessage));
      },
      (data) {
        reviewsModel = data;
        allReviewsList = allReviewsList + (data.data?.items ?? []);
        final totalPages = data.data?.metadata?.totalPages;
        hasMore = totalPages != null
            ? this.page < totalPages
            : (data.data?.items?.isNotEmpty ?? false);
        emit(GetReviewsSuccessState(reviewsModel: data));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isClosed || reviewsModel == null) return;
    isLoadingMore = true;
    emit(GetReviewsSuccessState(reviewsModel: reviewsModel!));
    try {
      await getReviews(page: page + 1, withLoading: false);
    } finally {
      if (!isClosed) {
        isLoadingMore = false;
        if (reviewsModel != null) {
          emit(GetReviewsSuccessState(reviewsModel: reviewsModel!));
        }
      }
    }
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}
