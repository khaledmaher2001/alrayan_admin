import '../../../data/models/delivery_account_model.dart';

abstract class GetDeliveryAccountsStates {}

class GetDeliveryAccountsInitState extends GetDeliveryAccountsStates {}

class GetDeliveryAccountsLoadingState extends GetDeliveryAccountsStates {}

class GetDeliveryAccountsSuccessState extends GetDeliveryAccountsStates {
  final DeliveryAccountsModel model;

  GetDeliveryAccountsSuccessState({required this.model});
}

class GetDeliveryAccountsErrorState extends GetDeliveryAccountsStates {
  final String message;

  GetDeliveryAccountsErrorState(this.message);
}
