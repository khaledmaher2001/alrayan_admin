import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/all_users/data/repo/all_users_repo.dart';
import 'delete_user_state.dart';

class DeleteUserCubit extends Cubit<DeleteUserState> {
  DeleteUserCubit(this.repo) : super(DeleteUserInitial());

  final AllUsersRepo repo;

  Future<void> deleteUser(int id) async {
    emit(DeleteUserLoading());
    final result = await repo.deleteUser(id);
    result.fold(
      (failure) => emit(DeleteUserError(failure.errMessage)),
      (_) => emit(DeleteUserSuccess()),
    );
  }
}
