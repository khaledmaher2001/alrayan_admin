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
