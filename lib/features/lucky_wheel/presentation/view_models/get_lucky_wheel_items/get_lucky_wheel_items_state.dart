part of 'get_lucky_wheel_items_cubit.dart';

abstract class GetLuckyWheelItemsState {}

class GetLuckyWheelItemsInitial extends GetLuckyWheelItemsState {}

class GetLuckyWheelItemsLoadingState extends GetLuckyWheelItemsState {}

class GetLuckyWheelItemsSuccessState extends GetLuckyWheelItemsState {
  final LuckyWheelModel model;

  GetLuckyWheelItemsSuccessState(this.model);
}

class GetLuckyWheelItemsErrorState extends GetLuckyWheelItemsState {
  final String error;

  GetLuckyWheelItemsErrorState(this.error);
}

class GetLuckyWheelToggleLoadingState extends GetLuckyWheelItemsState {}

class GetLuckyWheelToggleErrorState extends GetLuckyWheelItemsState {
  final String error;
  GetLuckyWheelToggleErrorState(this.error);
}

class GetLuckyWheelLuckyTimeChangedState extends GetLuckyWheelItemsState {
  final bool earningOpen;
  GetLuckyWheelLuckyTimeChangedState(this.earningOpen);
}
