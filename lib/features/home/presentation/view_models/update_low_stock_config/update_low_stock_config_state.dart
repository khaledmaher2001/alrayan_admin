import '../../../data/models/low_stock_config_model.dart';

abstract class UpdateLowStockConfigState {}

class UpdateLowStockConfigInitial extends UpdateLowStockConfigState {}

class UpdateLowStockConfigLoading extends UpdateLowStockConfigState {}

class UpdateLowStockConfigSuccess extends UpdateLowStockConfigState {
  final LowStockConfigModel config;

  UpdateLowStockConfigSuccess(this.config);
}

class UpdateLowStockConfigError extends UpdateLowStockConfigState {
  final String error;

  UpdateLowStockConfigError(this.error);
}
