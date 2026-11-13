import '../../../data/models/delivery_account_model.dart';

abstract class FindDeliveryAccountState {}

class FindDeliveryAccountInitial extends FindDeliveryAccountState {}

class FindDeliveryAccountLoading extends FindDeliveryAccountState {}

/// [account] is null when no courier has that id (e.g. deleted).
class FindDeliveryAccountSuccess extends FindDeliveryAccountState {
  final DeliveryAccount? account;

  FindDeliveryAccountSuccess(this.account);
}

class FindDeliveryAccountError extends FindDeliveryAccountState {
  final String message;

  FindDeliveryAccountError(this.message);
}
