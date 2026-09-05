import '../../../data/models/delivery_account_model.dart';

abstract class CreateDeliveryAccountState {}

class CreateDeliveryAccountInitial extends CreateDeliveryAccountState {}

class CreateDeliveryAccountLoading extends CreateDeliveryAccountState {}

class CreateDeliveryAccountSuccess extends CreateDeliveryAccountState {
  final DeliveryAccount account;

  CreateDeliveryAccountSuccess(this.account);
}

class CreateDeliveryAccountError extends CreateDeliveryAccountState {
  final String message;

  CreateDeliveryAccountError(this.message);
}
