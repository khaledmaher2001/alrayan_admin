import 'package:alrayan_admin/features/categories/data/models/sub_categories_model.dart';

abstract class GetSubCategoriesStates{}

class GetSubCategoriesInitState extends GetSubCategoriesStates{}
class GetSubCategoriesLoadingState extends GetSubCategoriesStates{}
class GetSubCategoriesSuccessState extends GetSubCategoriesStates{
  final SubCategoriesModel subCategoriesModel;

  GetSubCategoriesSuccessState({required this.subCategoriesModel});
}
class GetSubCategoriesErrorState extends GetSubCategoriesStates{}