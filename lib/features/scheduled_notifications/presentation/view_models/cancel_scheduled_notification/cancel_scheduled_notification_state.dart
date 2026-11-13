part of 'cancel_scheduled_notification_cubit.dart';

abstract class CancelScheduledNotificationState {}

class CancelScheduledNotificationInitial extends CancelScheduledNotificationState {}

class CancelScheduledNotificationLoadingState extends CancelScheduledNotificationState {
  final int id;
  CancelScheduledNotificationLoadingState(this.id);
}

class CancelScheduledNotificationSuccessState extends CancelScheduledNotificationState {}

class CancelScheduledNotificationErrorState extends CancelScheduledNotificationState {
  final String error;
  CancelScheduledNotificationErrorState(this.error);
}
