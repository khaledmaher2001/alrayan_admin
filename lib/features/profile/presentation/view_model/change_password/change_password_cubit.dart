import 'package:alrayan_admin/features/profile/data/repo/profile_repo/profile_repo.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/change_password/change_password_state.dart';
import 'package:bloc/bloc.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordStates> {
  ChangePasswordCubit(this.productsRepo) : super(ChangePasswordInitialState());
  ProfileRepo? productsRepo;

  Future<void> changePassword({required Map<String,dynamic> data}) async {
    emit(ChangePasswordLoadingState());

    var result = await productsRepo!.changePassword(data: data);
    return result.fold(
      (failure) {
        emit(ChangePasswordErrorState(failure.errMessage));
      },
      (data) {
        emit(ChangePasswordSuccessState(data));
      },
    );
  }
}
