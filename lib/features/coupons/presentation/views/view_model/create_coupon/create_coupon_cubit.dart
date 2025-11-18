import 'package:alrayan_admin/features/coupons/data/repo/coupons_repo.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/create_coupon/create_coupon_states.dart';
import 'package:bloc/bloc.dart';

class CreateCouponCubit extends Cubit<CreateCouponStates> {
  CreateCouponCubit(this.couponsRepo) : super(CreateCouponInitState());
  CouponsRepo? couponsRepo;

  Future<void> createCoupon({required Map<String, dynamic> data}) async {
    emit(CreateCouponLoadingState());
    var result = await couponsRepo!.createCoupon(data: data);
    return result.fold(
      (failure) {
        emit(CreateCouponErrorState(error: failure.errMessage));
      },
      (data) {
        emit(CreateCouponSuccessState(message: data));
      },
    );
  }
}
