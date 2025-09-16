part of 'send_otp_cubit.dart';

abstract class SendOtpState {}

class SendOtpInitial extends SendOtpState {}


class SendOtpLoadingState extends SendOtpState {}
class SendOtpSuccessState extends SendOtpState {
  final String message;

  SendOtpSuccessState(this.message);
}
class SendOtpErrorState extends SendOtpState {
  final String error;

  SendOtpErrorState(this.error);
}
