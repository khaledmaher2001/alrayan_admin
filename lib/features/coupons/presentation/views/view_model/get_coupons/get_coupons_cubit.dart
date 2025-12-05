import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/coupons_model.dart';
import '../../../../data/repo/coupons_repo.dart';

part 'get_coupons_state.dart';

class GetCouponsCubit extends Cubit<GetCouponsState> {
  GetCouponsCubit(this.repo) : super(GetCouponsInitial());

  CouponsRepo repo;

  CouponsModel? couponsModel;
  List<Items> couponsList = [];
  int page = 1;

  Future<void> getCoupons({bool withLoading = true}) async {
    if (withLoading) {
      couponsList.clear();
      couponsModel = null;
      page = 1;

      emit(GetCouponsLoadingState());
    }

    final result = await repo.getCoupons(page: page);
    result.fold(
      (failure) {
        emit(GetCouponsErrorState(failure.errMessage));
      },
      (data) async {
        couponsModel = data;
        couponsList = couponsList + data.data!.items!;
        emit(GetCouponsSuccessState(data));
      },
    );
  }
}
