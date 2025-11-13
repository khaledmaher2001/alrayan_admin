import 'package:bloc/bloc.dart';

import '../../../data/models/all_users_model.dart';
import '../../../data/repo/all_users_repo.dart';
import 'get_all_users_states.dart';

class GetAllUsersCubit extends Cubit<GetAllUsersStates> {
  GetAllUsersCubit(this.repo) : super(GetAllUsersInitState());
  AllUsersRepo? repo;

  List<Items> allUsersList = [];
  AllUsersModel? allUsersModel;
  int page = 1;

  Future<void> getAllUsers({required var data, bool withLoading = true}) async {
    if (withLoading) {
      allUsersModel = null;
      allUsersList.clear();
      page = 1;
      emit(GetAllUsersLoadingState());
    }
    var result = await repo!.getAllUsers(data: data );
    return result.fold(
      (failure) {
        emit(GetAllUsersErrorState());
      },
      (data) {
        allUsersModel = data;
        allUsersList = allUsersList + data.data!.items!;
        emit(GetAllUsersSuccessState(model: data));
      },
    );
  }
}
