import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/auth_repo.dart';

part 'verify_otp_state.dart';

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  VerifyOtpCubit(this.authRepo) : super(VerifyOtpInitial());

  AuthRepo authRepo;

  Future<void> verifyOtp({required String otp, required String email}) async {
    emit(VerifyOtpLoadingState());

    try {
      final result = await authRepo.verifyOtp(
        data: {"email": email, "otpCode": otp},
      );
      result.fold(
        (failure) {
          emit(VerifyOtpErrorState(failure.errMessage));
        },
        (data) async {
          emit(VerifyOtpSuccessState(data));
        },
      );
    } catch (e) {
      emit(VerifyOtpErrorState(e.toString()));
    }
  }
}
