import '../../../data/models/low_stock_product_model.dart';

abstract class GetLowStockProductsState {}

class GetLowStockProductsInitial extends GetLowStockProductsState {}

class GetLowStockProductsLoading extends GetLowStockProductsState {}

class GetLowStockProductsSuccess extends GetLowStockProductsState {
  final List<LowStockProductModel> products;

  GetLowStockProductsSuccess(this.products);
}

class GetLowStockProductsError extends GetLowStockProductsState {
  final String error;

  GetLowStockProductsError(this.error);
}
