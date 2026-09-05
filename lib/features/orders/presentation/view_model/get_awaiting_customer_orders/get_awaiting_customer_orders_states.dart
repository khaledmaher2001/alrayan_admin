import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';

abstract class GetAwaitingCustomerOrdersStates {}

class GetAwaitingCustomerOrdersInitState
    extends GetAwaitingCustomerOrdersStates {}

class GetAwaitingCustomerOrdersLoadingState
    extends GetAwaitingCustomerOrdersStates {}

class GetAwaitingCustomerOrdersSuccessState
    extends GetAwaitingCustomerOrdersStates {
  final OrdersModel model;

  GetAwaitingCustomerOrdersSuccessState({required this.model});
}

class GetAwaitingCustomerOrdersErrorState
    extends GetAwaitingCustomerOrdersStates {
  final String message;

  GetAwaitingCustomerOrdersErrorState(this.message);
}
