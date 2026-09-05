import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';

abstract class GetDeliveryOrdersStates {}

class GetDeliveryOrdersInitState extends GetDeliveryOrdersStates {}

class GetDeliveryOrdersLoadingState extends GetDeliveryOrdersStates {}

class GetDeliveryOrdersSuccessState extends GetDeliveryOrdersStates {
  final OrdersModel model;

  GetDeliveryOrdersSuccessState({required this.model});
}

class GetDeliveryOrdersErrorState extends GetDeliveryOrdersStates {
  final String message;

  GetDeliveryOrdersErrorState(this.message);
}
