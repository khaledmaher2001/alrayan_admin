part of 'get_loyalty_config_cubit.dart';

abstract class GetLoyaltyConfigState {}

class GetLoyaltyConfigInitial extends GetLoyaltyConfigState {}

class GetLoyaltyConfigLoadingState extends GetLoyaltyConfigState {}

class GetLoyaltyConfigSuccessState extends GetLoyaltyConfigState {
  final LoyaltyConfigModel configModel;

  GetLoyaltyConfigSuccessState({required this.configModel});
}

class GetLoyaltyConfigErrorState extends GetLoyaltyConfigState {
  final String errorMessage;

  GetLoyaltyConfigErrorState(this.errorMessage);
}
