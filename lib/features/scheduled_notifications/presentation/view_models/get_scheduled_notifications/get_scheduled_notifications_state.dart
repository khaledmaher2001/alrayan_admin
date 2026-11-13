part of 'get_scheduled_notifications_cubit.dart';

abstract class GetScheduledNotificationsState {}

class GetScheduledNotificationsInitial extends GetScheduledNotificationsState {}

class GetScheduledNotificationsLoadingState extends GetScheduledNotificationsState {}

class GetScheduledNotificationsSuccessState extends GetScheduledNotificationsState {}

class GetScheduledNotificationsErrorState extends GetScheduledNotificationsState {
  final String error;
  GetScheduledNotificationsErrorState(this.error);
}
