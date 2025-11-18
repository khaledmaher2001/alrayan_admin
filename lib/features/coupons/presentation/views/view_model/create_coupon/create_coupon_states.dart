abstract class CreateCouponStates {}

class CreateCouponInitState extends CreateCouponStates {}

class CreateCouponLoadingState extends CreateCouponStates {}

class CreateCouponSuccessState extends CreateCouponStates {
  final String message;

  CreateCouponSuccessState({required this.message});
}

class CreateCouponErrorState extends CreateCouponStates {
  final String error;

  CreateCouponErrorState({required this.error});
}
