
import '../../../data/models/home_statistics_model.dart';

abstract class GetHomeStatisticsStates {}

class GetHomeStatisticsInitState extends GetHomeStatisticsStates {}

class GetHomeStatisticsLoadingState extends GetHomeStatisticsStates {}

class GetHomeStatisticsSuccessState extends GetHomeStatisticsStates {
  final HomeStatisticsModel model;

  GetHomeStatisticsSuccessState({required this.model});
}

class GetHomeStatisticsErrorState extends GetHomeStatisticsStates {}
