import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repo/coupons_repo.dart';

part 'delete_coupon_state.dart';

class DeleteCouponCubit extends Cubit<DeleteCouponState> {
  DeleteCouponCubit(this.repo) : super(DeleteCouponInitial());

  CouponsRepo repo;

  int selectedIndex = -1;

  Future<void> deleteCoupon({required int couponId}) async {
    emit(DeleteCouponLoadingState());

    final result = await repo.deleteCoupon(couponId: couponId);
    result.fold(
      (failure) {
        emit(DeleteCouponErrorState(failure.errMessage));
      },
      (data) async {
        emit(DeleteCouponSuccessState(data));
      },
    );
  }
}
