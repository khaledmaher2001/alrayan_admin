import '../../../data/models/delivery_transaction_model.dart';

abstract class GetDeliveryTransactionsStates {}

class GetDeliveryTransactionsInitState extends GetDeliveryTransactionsStates {}

class GetDeliveryTransactionsLoadingState
    extends GetDeliveryTransactionsStates {}

class GetDeliveryTransactionsSuccessState
    extends GetDeliveryTransactionsStates {
  final DeliveryTransactionsModel model;

  GetDeliveryTransactionsSuccessState({required this.model});
}

class GetDeliveryTransactionsErrorState extends GetDeliveryTransactionsStates {
  final String message;

  GetDeliveryTransactionsErrorState(this.message);
}
