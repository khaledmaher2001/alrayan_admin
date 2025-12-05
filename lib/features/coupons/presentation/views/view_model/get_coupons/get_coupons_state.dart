part of 'get_coupons_cubit.dart';

abstract class GetCouponsState {}

class GetCouponsInitial extends GetCouponsState {}

class GetCouponsLoadingState extends GetCouponsState {}

class GetCouponsSuccessState extends GetCouponsState {
  final CouponsModel model;

  GetCouponsSuccessState(this.model);
}

class GetCouponsErrorState extends GetCouponsState {
  final String error;

  GetCouponsErrorState(this.error);
}
