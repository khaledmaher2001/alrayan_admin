abstract class CancelOrderStates {}

class CancelOrderInitState extends CancelOrderStates {}

class CancelOrderLoadingState extends CancelOrderStates {}

class CancelOrderSuccessState extends CancelOrderStates {
  final String message;

  CancelOrderSuccessState({required this.message});
}

class CancelOrderErrorState extends CancelOrderStates { final String error;

CancelOrderErrorState({required this.error});
}
