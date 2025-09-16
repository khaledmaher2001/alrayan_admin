import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/auth_repo_impl.dart';
part 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit(this.repo) : super(ForgetPasswordInitial());

  AuthRepoImpl repo;

  Future<void> forgetPassword({required String email}) async {
    emit(ForgetPasswordLoadingState());
    final result = await repo.forgetPassword(email: email);
    result.fold(
      (failure) {
        emit(ForgetPasswordErrorState(failure.errMessage));
      },
      (data) {
        emit(ForgetPasswordSuccessState(data));
      },
    );
  }
}
