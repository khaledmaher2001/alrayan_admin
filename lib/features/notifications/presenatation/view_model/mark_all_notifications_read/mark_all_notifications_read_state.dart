sealed class MarkAllNotificationsReadState {}

final class MarkAllNotificationsReadInitial extends MarkAllNotificationsReadState {}

class MarkAllNotificationsReadLoading extends MarkAllNotificationsReadState {}

final class MarkAllNotificationsReadSuccess extends MarkAllNotificationsReadState {}

final class MarkAllNotificationsReadError extends MarkAllNotificationsReadState {
  final String error;

  MarkAllNotificationsReadError(this.error);
}
