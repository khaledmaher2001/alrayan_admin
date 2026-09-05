import 'package:bloc/bloc.dart';

import '../../../data/repo/notifications_repo.dart';
import 'mark_all_notifications_read_state.dart';

class MarkAllNotificationsReadCubit extends Cubit<MarkAllNotificationsReadState> {
  NotificationsRepo repo;

  MarkAllNotificationsReadCubit(this.repo) : super(MarkAllNotificationsReadInitial());

  Future<void> markAllAsRead() async {
    emit(MarkAllNotificationsReadLoading());
    final result = await repo.markAllAsRead();
    result.fold(
      (failure) => emit(MarkAllNotificationsReadError(failure.errMessage)),
      (_) => emit(MarkAllNotificationsReadSuccess()),
    );
  }
}
