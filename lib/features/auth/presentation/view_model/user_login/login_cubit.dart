import 'package:alrayan_admin/core/utils/services/local_services/cache_helper.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/auth_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginStates> {

  LoginCubit(this.loginRepo) : super(LoginInitialState());
  final AuthRepo loginRepo;

  Future<void> userlogin({
    required String email,
    required String password,
  }) async {
    emit(LoginLoadingState());
   final result = await loginRepo.userLogin(
      email: email,
      password: password,
    );
     result.fold((failure) {
      emit(LoginErrorState(failure.errMessage));
    }, (data) async {
      emit(LoginSuccessState(data));
    });
  }
}
