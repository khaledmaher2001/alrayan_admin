import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';

import '../../../data/models/all_users_model.dart';
import '../../../data/repo/all_users_repo.dart';
import 'get_all_users_states.dart';

class GetAllUsersCubit extends Cubit<GetAllUsersStates> with RequestGuardMixin {
  GetAllUsersCubit(this.repo) : super(GetAllUsersInitState());
  AllUsersRepo? repo;

  List<Items> allUsersList = [];
  AllUsersModel? allUsersModel;
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  String? keyword;

  static const int _limit = 12;

  void removeUser(int id) {
    allUsersList.removeWhere((u) => u.id == id);
    if (allUsersModel != null) {
      emit(GetAllUsersSuccessState(model: allUsersModel!));
    }
  }

  Future<void> getAllUsers({String? keyword, bool withLoading = true}) async {
    // A null keyword keeps the current one; pass '' explicitly to clear it.
    if (keyword != null) this.keyword = keyword.trim();

    final reqId = beginRequest();
    if (withLoading) {
      allUsersModel = null;
      allUsersList.clear();
      page = 1;
      hasMore = true;
      emit(GetAllUsersLoadingState());
    }

    final result = await repo!.getAllUsers(
      data: {
        'page': page,
        'limit': _limit,
        if ((this.keyword ?? '').isNotEmpty) 'keyword': this.keyword,
      },
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;

    return result.fold(
      (failure) {
        emit(GetAllUsersErrorState());
      },
      (data) {
        allUsersModel = data;
        allUsersList = allUsersList + (data.data?.items ?? []);
        final totalPages = data.data?.metadata?.totalPages;
        hasMore = totalPages != null
            ? page < totalPages
            : (data.data?.items?.isNotEmpty ?? false);
        emit(GetAllUsersSuccessState(model: data));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isClosed || allUsersModel == null) return;
    isLoadingMore = true;
    emit(GetAllUsersSuccessState(model: allUsersModel!));
    page++;
    try {
      await getAllUsers(withLoading: false);
    } finally {
      if (!isClosed) {
        isLoadingMore = false;
        if (allUsersModel != null) {
          emit(GetAllUsersSuccessState(model: allUsersModel!));
        }
      }
    }
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}
