part of 'delete_banner_cubit.dart';

abstract class DeleteBannersState {}

class DeleteBannersInitial extends DeleteBannersState {}

class DeleteBannersLoading extends DeleteBannersState {}

class DeleteBannersError extends DeleteBannersState {
  final String message;
  DeleteBannersError(this.message);
}

class DeleteBannersLoaded extends DeleteBannersState {
  final String message;

  DeleteBannersLoaded(this.message );
}
