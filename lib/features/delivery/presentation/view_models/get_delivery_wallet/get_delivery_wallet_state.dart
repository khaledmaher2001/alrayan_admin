import '../../../data/models/delivery_wallet_model.dart';

abstract class GetDeliveryWalletState {}

class GetDeliveryWalletInitial extends GetDeliveryWalletState {}

class GetDeliveryWalletLoading extends GetDeliveryWalletState {}

class GetDeliveryWalletSuccess extends GetDeliveryWalletState {
  final DeliveryWalletModel model;

  GetDeliveryWalletSuccess(this.model);
}

class GetDeliveryWalletError extends GetDeliveryWalletState {
  final String message;

  GetDeliveryWalletError(this.message);
}
