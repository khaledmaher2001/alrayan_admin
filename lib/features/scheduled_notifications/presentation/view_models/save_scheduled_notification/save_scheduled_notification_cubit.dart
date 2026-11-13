import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/scheduled_notification_model.dart';
import '../../../data/repo/scheduled_notifications_repo.dart';

part 'save_scheduled_notification_state.dart';

/// Create / edit form: uploads the picked image, then creates or updates.
class SaveScheduledNotificationCubit extends Cubit<SaveScheduledNotificationState> {
  SaveScheduledNotificationCubit(this.repo) : super(SaveScheduledNotificationInitial());

  final ScheduledNotificationsRepo repo;

  Future<void> uploadImage(String filePath) async {
    emit(ScheduledImageUploadingState());
    final result = await repo.uploadImage(filePath);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ScheduledImageUploadErrorState(failure.errMessage)),
      (image) => emit(ScheduledImageUploadedState(image)),
    );
  }

  Future<void> save({int? id, required Map<String, dynamic> body, required bool sentNow}) async {
    emit(SaveScheduledNotificationLoadingState());
    final result = id == null
        ? await repo.createScheduledNotification(body)
        : await repo.updateScheduledNotification(id, body);
    if (isClosed) return;
    result.fold(
      (failure) => emit(SaveScheduledNotificationErrorState(failure.errMessage)),
      (item) => emit(SaveScheduledNotificationSuccessState(item, edited: id != null, sentNow: sentNow)),
    );
  }
}
