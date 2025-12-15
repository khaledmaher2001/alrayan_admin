part of 'get_top_products_cubit.dart';

abstract class GetTopProductsState {}

class GetTopProductsInitial extends GetTopProductsState {}

class GetTopProductsLoading extends GetTopProductsState {}

class GetTopProductsError extends GetTopProductsState {
  final String message;
  GetTopProductsError(this.message);
}

class GetTopProductsLoaded extends GetTopProductsState {
  final List<TopSellingProducts> users;

  GetTopProductsLoaded(this.users);
}
