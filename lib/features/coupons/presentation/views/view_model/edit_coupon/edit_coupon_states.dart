abstract class EditCouponStates {}

class EditCouponInitState extends EditCouponStates {}

class EditCouponLoadingState extends EditCouponStates {}

class EditCouponSuccessState extends EditCouponStates {
  final String message;

  EditCouponSuccessState({required this.message});
}

class EditCouponErrorState extends EditCouponStates {
  final String error;

  EditCouponErrorState({required this.error});
}
