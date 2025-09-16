

import '../../../data/model/notifications_model.dart';

sealed class GetNotificationsState {}

final class GetNotificationsInitial extends GetNotificationsState {}

class GetNotificationsLoading extends GetNotificationsState {}

final class GetNotificationsSuccess extends GetNotificationsState {
  final NotificationsModel model;

  GetNotificationsSuccess(this.model);
}

final class GetNotificationsError extends GetNotificationsState {
  final String error;

  GetNotificationsError(this.error);
}
