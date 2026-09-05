import '../../../data/models/inventory_analytics_model.dart';

abstract class GetInventoryAnalyticsState {}

class GetInventoryAnalyticsInitial extends GetInventoryAnalyticsState {}

class GetInventoryAnalyticsLoading extends GetInventoryAnalyticsState {}

class GetInventoryAnalyticsSuccess extends GetInventoryAnalyticsState {
  final List<InventoryAnalyticsModel> items;

  GetInventoryAnalyticsSuccess(this.items);
}

class GetInventoryAnalyticsError extends GetInventoryAnalyticsState {
  final String error;

  GetInventoryAnalyticsError(this.error);
}
