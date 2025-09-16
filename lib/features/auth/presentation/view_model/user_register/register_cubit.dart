import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/auth_repo.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterStates> {

  RegisterCubit(this.registerRepo) : super(RegisterInitialState());
  final AuthRepo registerRepo;

  Future<void> userRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    emit(RegisterLoadingState());
   final result = await registerRepo.userRegister(
     name: name,
      email: email,
      password: password,
     phone: phone,
    );
     result.fold((failure) {
      emit(RegisterErrorState(failure.errMessage));
    },
             (success) {
      emit(RegisterSuccessState(success));
    });
  }
}
