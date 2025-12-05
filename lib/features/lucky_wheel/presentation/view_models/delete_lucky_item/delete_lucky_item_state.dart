part of 'delete_lucky_item_cubit.dart';

abstract class DeleteLuckyItemState {}

class DeleteLuckyItemInitial extends DeleteLuckyItemState {}

class DeleteLuckyItemLoadingState extends DeleteLuckyItemState {}

class DeleteLuckyItemSuccessState extends DeleteLuckyItemState {
  final String message;

  DeleteLuckyItemSuccessState(this.message);
}

class DeleteLuckyItemErrorState extends DeleteLuckyItemState {
  final String error;

  DeleteLuckyItemErrorState(this.error);
}
