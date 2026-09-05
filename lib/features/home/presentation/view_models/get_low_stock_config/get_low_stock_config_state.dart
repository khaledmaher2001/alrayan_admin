import '../../../data/models/low_stock_config_model.dart';

abstract class GetLowStockConfigState {}

class GetLowStockConfigInitial extends GetLowStockConfigState {}

class GetLowStockConfigLoading extends GetLowStockConfigState {}

class GetLowStockConfigSuccess extends GetLowStockConfigState {
  final LowStockConfigModel config;

  GetLowStockConfigSuccess(this.config);
}

class GetLowStockConfigError extends GetLowStockConfigState {
  final String error;

  GetLowStockConfigError(this.error);
}
