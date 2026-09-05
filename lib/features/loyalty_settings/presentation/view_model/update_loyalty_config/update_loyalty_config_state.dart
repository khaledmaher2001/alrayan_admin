import '../../../data/models/loyalty_config_model.dart';

abstract class UpdateLoyaltyConfigState {}

class UpdateLoyaltyConfigInitialState extends UpdateLoyaltyConfigState {}

class UpdateLoyaltyConfigLoadingState extends UpdateLoyaltyConfigState {}

class UpdateLoyaltyConfigSuccessState extends UpdateLoyaltyConfigState {
  final LoyaltyConfigModel configModel;

  UpdateLoyaltyConfigSuccessState(this.configModel);
}

class UpdateLoyaltyConfigErrorState extends UpdateLoyaltyConfigState {
  final String errorMessage;

  UpdateLoyaltyConfigErrorState(this.errorMessage);
}
