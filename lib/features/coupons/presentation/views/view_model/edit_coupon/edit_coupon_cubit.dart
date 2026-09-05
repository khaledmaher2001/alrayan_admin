import 'package:alrayan_admin/features/coupons/data/repo/coupons_repo.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/edit_coupon/edit_coupon_states.dart';
import 'package:bloc/bloc.dart';

class EditCouponCubit extends Cubit<EditCouponStates> {
  EditCouponCubit(this.couponsRepo) : super(EditCouponInitState());
  CouponsRepo? couponsRepo;

  Future<void> updateCoupon({required int couponId, required Map<String, dynamic> data}) async {
    emit(EditCouponLoadingState());
    var result = await couponsRepo!.updateCoupon(couponId: couponId, data: data);
    return result.fold(
      (failure) {
        emit(EditCouponErrorState(error: failure.errMessage));
      },
      (data) {
        emit(EditCouponSuccessState(message: data));
      },
    );
  }
}
