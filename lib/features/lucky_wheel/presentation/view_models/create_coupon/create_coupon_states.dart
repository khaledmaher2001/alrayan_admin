abstract class CreateLuckyItemStates {}

class CreateLuckyItemInitState extends CreateLuckyItemStates {}

class CreateLuckyItemLoadingState extends CreateLuckyItemStates {}

class CreateLuckyItemSuccessState extends CreateLuckyItemStates {
  final String message;

  CreateLuckyItemSuccessState({required this.message});
}

class CreateLuckyItemErrorState extends CreateLuckyItemStates {
  final String error;

  CreateLuckyItemErrorState({required this.error});
}
