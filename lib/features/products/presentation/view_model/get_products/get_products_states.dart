import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/features/products/data/models/products_model.dart';

abstract class GetProductsStates{}

class GetProductsInitState extends GetProductsStates{}
class GetProductsLoadingState extends GetProductsStates{}
class GetProductsSuccessState extends GetProductsStates{
  final ProductsModel productsModel;

  GetProductsSuccessState({required this.productsModel});
}
class GetProductsErrorState extends GetProductsStates{
  final String error;
  GetProductsErrorState({String? error}) : error = error ?? "s_something_went_wrong_please_try_agai".tr();
}