import 'package:bloc/bloc.dart';

import '../../../data/model/notifications_model.dart';
import '../../../data/repo/notifications_repo.dart';
import 'get_notifications_state.dart';

class GetNotificationsCubit extends Cubit<GetNotificationsState> {
  NotificationsRepo repo;

  GetNotificationsCubit(this.repo) : super(GetNotificationsInitial());

  List<Items> notificationsList = [];
  NotificationsModel? notificationsModel;
  int page = 1;

  Future<void> getNotifications({bool withLoading = true}) async {
    if (withLoading) {
      page = 1;
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
      );
      result.fold(
        (failure) {
          emit(GetNotificationsError(failure.errMessage));
        },
        (data) {
          notificationsModel = data;
          notificationsList = notificationsList + data.data!.items!;
          emit(GetNotificationsSuccess(data));
        },
      );
    } catch (e) {
      emit(GetNotificationsError(e.toString()));
    }
  }
}
