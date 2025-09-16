import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/auth_repo_impl.dart';
part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit(this.repo) : super(ResetPasswordInitial());

  AuthRepoImpl repo;

  Future<void> resetPassword({required Map<String,dynamic> data}) async {
    emit(ResetPasswordLoadingState());
    final result = await repo.resetPassword(data: data);
    result.fold(
      (failure) {
        emit(ResetPasswordErrorState(failure.errMessage));
      },
      (data) {
        emit(ResetPasswordSuccessState(data));
      },
    );
  }
}
