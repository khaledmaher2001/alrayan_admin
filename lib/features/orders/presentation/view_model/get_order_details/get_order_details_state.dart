part of 'get_order_details_cubit.dart';

abstract class GetOrderDetailsState {}

class GetOrderDetailsInitial extends GetOrderDetailsState {}

class GetOrderDetailsLoadingState extends GetOrderDetailsState {}

class GetOrderDetailsSuccessState extends GetOrderDetailsState {
  final Items orderDetailsModel;

  GetOrderDetailsSuccessState({required this.orderDetailsModel});
}

class GetOrderDetailsErrorState extends GetOrderDetailsState {
  final String error;

  GetOrderDetailsErrorState(this.error);
}
