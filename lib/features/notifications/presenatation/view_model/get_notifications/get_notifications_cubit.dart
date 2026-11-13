import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';

import '../../../data/model/notifications_model.dart';
import '../../../data/repo/notifications_repo.dart';
import 'get_notifications_state.dart';

class GetNotificationsCubit extends Cubit<GetNotificationsState>
    with RequestGuardMixin {
  NotificationsRepo repo;

  GetNotificationsCubit(this.repo) : super(GetNotificationsInitial());

  List<Items> notificationsList = [];
  NotificationsModel? notificationsModel;
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  Future<void> getNotifications({bool withLoading = true}) async {
    final reqId = beginRequest();
    if (withLoading) {
      page = 1;
      hasMore = true;
      notificationsList.clear();
      notificationsModel = null;
      emit(GetNotificationsLoading());
    }
    try {
      final result = await repo.getNotifications(
        data: {
          "page": page,
          "limit": 10,
        },
        cancelToken: requestCancelToken,
      );
      if (!isCurrentRequest(reqId)) return;
      result.fold(
        (failure) {
          emit(GetNotificationsError(failure.errMessage));
        },
        (data) {
          notificationsModel = data;
          notificationsList = notificationsList + (data.data?.items ?? []);
          final totalPages = data.data?.metadata?.totalPages;
          hasMore = totalPages != null
              ? page < totalPages
              : (data.data?.items?.isNotEmpty ?? false);
          emit(GetNotificationsSuccess(data));
        },
      );
    } catch (e) {
      if (!isCurrentRequest(reqId)) return;
      emit(GetNotificationsError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isClosed || notificationsModel == null) {
      return;
    }
    isLoadingMore = true;
    emit(GetNotificationsSuccess(notificationsModel!));
    page++;
    try {
      await getNotifications(withLoading: false);
    } finally {
      if (!isClosed) {
        isLoadingMore = false;
        if (notificationsModel != null) {
          emit(GetNotificationsSuccess(notificationsModel!));
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
