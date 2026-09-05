import '../../../data/models/delivery_account_model.dart';

abstract class UpdateDeliveryProfileState {}

class UpdateDeliveryProfileInitial extends UpdateDeliveryProfileState {}

class UpdateDeliveryProfileLoading extends UpdateDeliveryProfileState {}

class UpdateDeliveryProfileSuccess extends UpdateDeliveryProfileState {
  final DeliveryAccount account;

  UpdateDeliveryProfileSuccess(this.account);
}

class UpdateDeliveryProfileError extends UpdateDeliveryProfileState {
  final String message;

  UpdateDeliveryProfileError(this.message);
}
