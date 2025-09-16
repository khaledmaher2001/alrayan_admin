import 'package:alrayan_admin/features/products/data/models/products_model.dart';

abstract class GetProductsDetailsStates{}

class GetProductsDetailsInitState extends GetProductsDetailsStates{}
class GetProductsDetailsLoadingState extends GetProductsDetailsStates{}
class GetProductsDetailsSuccessState extends GetProductsDetailsStates{
  final Data productDetails;

  GetProductsDetailsSuccessState({required this.productDetails});
}
class GetProductsDetailsErrorState extends GetProductsDetailsStates{}