

import '../../../data/model/notifications_model.dart';

sealed class ReadMarkNotificationsState {}

final class ReadMarkNotificationsInitial extends ReadMarkNotificationsState {}

class ReadMarkNotificationsLoading extends ReadMarkNotificationsState {}

final class ReadMarkNotificationsSuccess extends ReadMarkNotificationsState {
  final String message;

  ReadMarkNotificationsSuccess(this.message);
}

final class ReadMarkNotificationsError extends ReadMarkNotificationsState {
  final String error;

  ReadMarkNotificationsError(this.error);
}
