part of 'edit_lucky_item_cubit.dart';

abstract class EditLuckyItemState {}

class EditLuckyItemInitial extends EditLuckyItemState {}

class EditLuckyItemLoadingState extends EditLuckyItemState {}

class EditLuckyItemSuccessState extends EditLuckyItemState {
  final String message;
  EditLuckyItemSuccessState(this.message);
}

class EditLuckyItemErrorState extends EditLuckyItemState {
  final String error;
  EditLuckyItemErrorState(this.error);
}
