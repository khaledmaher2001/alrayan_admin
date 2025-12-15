import 'package:alrayan_admin/features/top_users/data/repo/top_users_repo.dart';
import 'package:bloc/bloc.dart';

import '../../../../home/data/models/home_statistics_model.dart';

part 'get_top_users_state.dart';

class GetTopUsersCubit extends Cubit<GetTopUsersState> {
  final TopUsersRepo repo;

  GetTopUsersCubit(this.repo) : super(GetTopUsersInitial());

  List<TopCustomers> users = [];

  Future<void> getTopUsers() async {
    emit(GetTopUsersLoading());
    var result = await repo.getTopUsers();
    result.fold(
          (failure) => emit(GetTopUsersError(failure.errMessage)),
          (users) {
        users = users;
        emit(GetTopUsersLoaded(users));
      },
    );
  }

}

