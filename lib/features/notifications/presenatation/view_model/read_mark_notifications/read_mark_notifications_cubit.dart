import 'package:alrayan_admin/features/notifications/presenatation/view_model/read_mark_notifications/read_mark_notifications_state.dart';
import 'package:bloc/bloc.dart';

import '../../../data/repo/notifications_repo.dart';

class ReadMarkNotificationsCubit extends Cubit<ReadMarkNotificationsState> {
  NotificationsRepo repo;

  ReadMarkNotificationsCubit(this.repo) : super(ReadMarkNotificationsInitial());

  Future<void> readMarkNotification({required int notificationId}) async {
    emit(ReadMarkNotificationsLoading());
    try {
      final result = await repo.readMarkNotification(notificationId: notificationId);
      result.fold(
        (failure) {
          emit(ReadMarkNotificationsError(failure.errMessage));
        },
        (data) {
          emit(ReadMarkNotificationsSuccess(data));
        },
      );
    } catch (e) {
      emit(ReadMarkNotificationsError(e.toString()));
    }
  }
}
