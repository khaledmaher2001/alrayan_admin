import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';

import '../../../../data/models/coupons_model.dart';
import '../../../../data/repo/coupons_repo.dart';

part 'get_coupons_state.dart';

class GetCouponsCubit extends Cubit<GetCouponsState> with RequestGuardMixin {
  GetCouponsCubit(this.repo) : super(GetCouponsInitial());

  CouponsRepo repo;

  CouponsModel? couponsModel;
  List<Items> couponsList = [];
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  Future<void> getCoupons({bool withLoading = true}) async {
    final reqId = beginRequest();
    if (withLoading) {
      couponsList.clear();
      couponsModel = null;
      page = 1;
      hasMore = true;
      emit(GetCouponsLoadingState());
    }

    final result = await repo.getCoupons(
      page: page,
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;

    result.fold(
      (failure) {
        emit(GetCouponsErrorState(failure.errMessage));
      },
      (data) {
        couponsModel = data;
        couponsList = couponsList + (data.data?.items ?? []);
        final totalPages = data.data?.metadata?.totalPages;
        hasMore = totalPages != null
            ? page < totalPages
            : (data.data?.items?.isNotEmpty ?? false);
        emit(GetCouponsSuccessState(data));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isClosed || couponsModel == null) return;
    isLoadingMore = true;
    emit(GetCouponsSuccessState(couponsModel!));
    page++;
    try {
      await getCoupons(withLoading: false);
    } finally {
      if (!isClosed) {
        isLoadingMore = false;
        if (couponsModel != null) emit(GetCouponsSuccessState(couponsModel!));
      }
    }
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}
