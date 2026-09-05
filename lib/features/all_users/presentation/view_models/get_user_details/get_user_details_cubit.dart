import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/all_users/data/repo/all_users_repo.dart';
import 'get_user_details_state.dart';

class GetUserDetailsCubit extends Cubit<GetUserDetailsState> {
  GetUserDetailsCubit(this.repo) : super(GetUserDetailsInitial());

  final AllUsersRepo repo;

  Future<void> getUserById(int id) async {
    emit(GetUserDetailsLoading());
    final result = await repo.getUserById(id);
    result.fold(
      (failure) => emit(GetUserDetailsError(failure.errMessage)),
      (user) => emit(GetUserDetailsSuccess(user)),
    );
  }
}
