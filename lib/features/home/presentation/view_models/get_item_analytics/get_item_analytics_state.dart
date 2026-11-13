import 'package:alrayan_admin/features/home/data/models/item_analytics_model.dart';

abstract class GetItemAnalyticsState {}

class GetItemAnalyticsInitial extends GetItemAnalyticsState {}

class GetItemAnalyticsLoading extends GetItemAnalyticsState {}

class GetItemAnalyticsSuccess extends GetItemAnalyticsState {
  GetItemAnalyticsSuccess(this.analytics);

  final ItemAnalyticsModel analytics;
}

class GetItemAnalyticsError extends GetItemAnalyticsState {
  GetItemAnalyticsError(this.message);

  final String message;
}
