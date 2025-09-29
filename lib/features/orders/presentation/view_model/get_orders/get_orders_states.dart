import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';

abstract class GetOrdersStates {}

class GetOrdersInitState extends GetOrdersStates {}

class GetOrdersLoadingState extends GetOrdersStates {}

class GetOrdersSuccessState extends GetOrdersStates {
  final OrdersModel model;

  GetOrdersSuccessState({required this.model});
}

class GetOrdersErrorState extends GetOrdersStates {}
