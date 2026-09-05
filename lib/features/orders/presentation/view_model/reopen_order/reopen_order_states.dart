abstract class ReopenOrderStates {}

class ReopenOrderInitState extends ReopenOrderStates {}

class ReopenOrderLoadingState extends ReopenOrderStates {}

class ReopenOrderSuccessState extends ReopenOrderStates {
  final String message;

  ReopenOrderSuccessState({required this.message});
}

class ReopenOrderErrorState extends ReopenOrderStates {
  final String error;

  ReopenOrderErrorState({required this.error});
}
