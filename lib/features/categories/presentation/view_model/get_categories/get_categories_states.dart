import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';

abstract class GetCategoriesStates{}

class GetCategoriesInitState extends GetCategoriesStates{}
class GetCategoriesLoadingState extends GetCategoriesStates{}
class GetCategoriesSuccessState extends GetCategoriesStates{
  final CategoriesModel categoriesModel;

  GetCategoriesSuccessState({required this.categoriesModel});
}
class GetCategoriesErrorState extends GetCategoriesStates{}