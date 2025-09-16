part of 'reset_password_cubit.dart';

abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}


class ResetPasswordLoadingState extends ResetPasswordState {}
class ResetPasswordSuccessState extends ResetPasswordState {
  final String message;

  ResetPasswordSuccessState(this.message);
}
class ResetPasswordErrorState extends ResetPasswordState {
  final String error;

  ResetPasswordErrorState(this.error);
}
