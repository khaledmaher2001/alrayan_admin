import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/services/local_services/cache_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/auth_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginStates> {

  LoginCubit(this.loginRepo) : super(LoginInitialState());
  final AuthRepo loginRepo;

  Future<void> userlogin({
    required String identifier,
    required String password,
  }) async {
    emit(LoginLoadingState());
   final result = await loginRepo.userLogin(
      identifier: identifier,
      password: password,
    );
     result.fold((failure) {
      emit(LoginErrorState(failure.errMessage));
    }, (data) async {
      final role = data.data?.role;
      // Only block when the server actually reports a non-admin role;
      // if it's missing we can't verify it, so let the login through.
      if (role != null && role.toLowerCase() != 'admin') {
        emit(LoginErrorState("s_you_re_not_allowed_to_sign_in".tr()));
        return;
      }
      await CacheHelper.saveData(key: "token", value: data.data!.accessToken);
      emit(LoginSuccessState(data));
    });
  }
}
