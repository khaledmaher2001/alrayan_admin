part of 'save_scheduled_notification_cubit.dart';

abstract class SaveScheduledNotificationState {}

class SaveScheduledNotificationInitial extends SaveScheduledNotificationState {}

class ScheduledImageUploadingState extends SaveScheduledNotificationState {}

class ScheduledImageUploadedState extends SaveScheduledNotificationState {
  final UploadedImage image;
  ScheduledImageUploadedState(this.image);
}

class ScheduledImageUploadErrorState extends SaveScheduledNotificationState {
  final String error;
  ScheduledImageUploadErrorState(this.error);
}

class SaveScheduledNotificationLoadingState extends SaveScheduledNotificationState {}

class SaveScheduledNotificationSuccessState extends SaveScheduledNotificationState {
  final ScheduledNotificationModel item;

  /// true = edited, false = created.
  final bool edited;

  /// Created to go out right away (not at a later time).
  final bool sentNow;
  SaveScheduledNotificationSuccessState(this.item, {required this.edited, required this.sentNow});
}

class SaveScheduledNotificationErrorState extends SaveScheduledNotificationState {
  final String error;
  SaveScheduledNotificationErrorState(this.error);
}
