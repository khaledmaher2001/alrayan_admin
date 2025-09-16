part of 'forget_password_cubit.dart';

abstract class ForgetPasswordState {}

class ForgetPasswordInitial extends ForgetPasswordState {}


class ForgetPasswordLoadingState extends ForgetPasswordState {}
class ForgetPasswordSuccessState extends ForgetPasswordState {
  final String message;

  ForgetPasswordSuccessState(this.message);
}
class ForgetPasswordErrorState extends ForgetPasswordState {
  final String error;

  ForgetPasswordErrorState(this.error);
}
