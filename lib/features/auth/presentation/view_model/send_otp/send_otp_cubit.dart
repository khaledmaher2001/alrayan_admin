import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/auth_repo.dart';

part 'send_otp_state.dart';

class SendOtpCubit extends Cubit<SendOtpState> {
  SendOtpCubit(this.authRepo) : super(SendOtpInitial());

  AuthRepo authRepo;

  Future<void> sendOtp({required String email}) async {
    emit(SendOtpLoadingState());
    final result = await authRepo.sendOtp(email: email);
    result.fold(
      (failure) {
        emit(SendOtpErrorState(failure.errMessage));
      },
      (data) async {
        emit(SendOtpSuccessState(data));
      },
    );
  }
}
