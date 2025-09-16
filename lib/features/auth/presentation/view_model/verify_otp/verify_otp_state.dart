part of 'verify_otp_cubit.dart';

abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}


class VerifyOtpLoadingState extends VerifyOtpState {}
class VerifyOtpSuccessState extends VerifyOtpState {
  final bool success;

  VerifyOtpSuccessState(this.success);
}
class VerifyOtpErrorState extends VerifyOtpState {
  final String error;

  VerifyOtpErrorState(this.error);
}
