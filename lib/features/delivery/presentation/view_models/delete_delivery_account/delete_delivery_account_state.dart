abstract class DeleteDeliveryAccountState {}

class DeleteDeliveryAccountInitial extends DeleteDeliveryAccountState {}

class DeleteDeliveryAccountLoading extends DeleteDeliveryAccountState {}

class DeleteDeliveryAccountSuccess extends DeleteDeliveryAccountState {}

class DeleteDeliveryAccountError extends DeleteDeliveryAccountState {
  final String message;

  DeleteDeliveryAccountError(this.message);
}
