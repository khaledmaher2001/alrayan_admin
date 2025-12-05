part of 'delete_coupon_cubit.dart';

abstract class DeleteCouponState {}

class DeleteCouponInitial extends DeleteCouponState {}

class DeleteCouponLoadingState extends DeleteCouponState {}

class DeleteCouponSuccessState extends DeleteCouponState {
  final String message;

  DeleteCouponSuccessState(this.message);
}

class DeleteCouponErrorState extends DeleteCouponState {
  final String error;

  DeleteCouponErrorState(this.error);
}
