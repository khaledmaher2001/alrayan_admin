import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/reviews_summery_model.dart';
import '../../../data/repo/reviews_repo.dart';

part 'get_reviews_summery_state.dart';

class GetReviewsSummeryCubit extends Cubit<GetReviewsSummeryState> {
  GetReviewsSummeryCubit(this.repo) : super(GetReviewsSummeryInitial());

  ReviewsRepo repo;

  Future<void> getReviewsSummery() async {
    emit(GetReviewsSummeryLoadingState());

    final result = await repo.getReviewsSummery();
    result.fold(
      (failure) {
        emit(GetReviewsSummeryErrorState(failure.errMessage));
      },
      (data) {
        emit(GetReviewsSummerySuccessState(summeryModel: data));
      },
    );
  }
}
