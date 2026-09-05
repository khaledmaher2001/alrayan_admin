import '../../../data/models/delivery_statistics_model.dart';

abstract class GetDeliveryStatisticsStates {}

class GetDeliveryStatisticsInitState extends GetDeliveryStatisticsStates {}

class GetDeliveryStatisticsLoadingState extends GetDeliveryStatisticsStates {}

class GetDeliveryStatisticsSuccessState extends GetDeliveryStatisticsStates {
  final DeliveryStatisticsModel model;

  GetDeliveryStatisticsSuccessState(this.model);
}

class GetDeliveryStatisticsErrorState extends GetDeliveryStatisticsStates {
  final String errMessage;

  GetDeliveryStatisticsErrorState(this.errMessage);
}
