abstract class DeleteUserState {}

class DeleteUserInitial extends DeleteUserState {}

class DeleteUserLoading extends DeleteUserState {}

class DeleteUserSuccess extends DeleteUserState {}

class DeleteUserError extends DeleteUserState {
  final String message;
  DeleteUserError(this.message);
}
