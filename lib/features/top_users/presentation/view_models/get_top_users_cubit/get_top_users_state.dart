part of 'get_top_users_cubit.dart';

abstract class GetTopUsersState {}

class GetTopUsersInitial extends GetTopUsersState {}

class GetTopUsersLoading extends GetTopUsersState {}

class GetTopUsersError extends GetTopUsersState {
  final String message;
  GetTopUsersError(this.message);
}

class GetTopUsersLoaded extends GetTopUsersState {
  final List<TopCustomers> users;

  GetTopUsersLoaded(this.users);
}
