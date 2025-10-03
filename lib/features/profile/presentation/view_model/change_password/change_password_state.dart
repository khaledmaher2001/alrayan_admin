
sealed class ChangePasswordStates {}

final class ChangePasswordInitialState extends ChangePasswordStates {}

final class ChangePasswordLoadingState extends ChangePasswordStates {}

final class ChangePasswordSuccessState extends ChangePasswordStates {
  final String message;

  ChangePasswordSuccessState(this.message);
}

final class ChangePasswordErrorState extends ChangePasswordStates {
  final String error;

  ChangePasswordErrorState(this.error);
}


