import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/scheduled_notifications_repo.dart';

part 'cancel_scheduled_notification_state.dart';

/// Stops a scheduled push (a repeating one stops repeating).
class CancelScheduledNotificationCubit extends Cubit<CancelScheduledNotificationState> {
  CancelScheduledNotificationCubit(this.repo) : super(CancelScheduledNotificationInitial());

  final ScheduledNotificationsRepo repo;

  Future<void> cancel(int id) async {
    emit(CancelScheduledNotificationLoadingState(id));
    final result = await repo.cancelScheduledNotification(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(CancelScheduledNotificationErrorState(failure.errMessage)),
      (_) => emit(CancelScheduledNotificationSuccessState()),
    );
  }
}
