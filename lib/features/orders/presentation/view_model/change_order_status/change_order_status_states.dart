abstract class ChangeOrderStatusStates {}

class ChangeOrderStatusInitState extends ChangeOrderStatusStates {}

class ChangeOrderStatusLoadingState extends ChangeOrderStatusStates {}

class ChangeOrderStatusSuccessState extends ChangeOrderStatusStates {
  final String message;

  ChangeOrderStatusSuccessState({required this.message});
}

class ChangeOrderStatusErrorState extends ChangeOrderStatusStates { final String error;

ChangeOrderStatusErrorState({required this.error});
}
