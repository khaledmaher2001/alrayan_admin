import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_states.dart';
import 'package:bloc/bloc.dart';

class ChangeCategoryCubit extends Cubit<ChangeCategoryStates> {
  ChangeCategoryCubit() : super(ChangeCategoryInitState());

  int selectedCategoryIndex = 0;

  void selectCategory({required int categoryIndex, int? categoryId}) {
    selectedCategoryIndex = categoryIndex;
    AppConstants.mainCategoryId = categoryId;
    emit(SelectCategoryState());
  }

  int selectedSubCategoryIndex = 0;

  void selectSubCategory({required int subCategoryIndex, int? subCategoryId}) {
    selectedSubCategoryIndex = subCategoryIndex;
    AppConstants.subCategoryId = subCategoryId;
    emit(SelectSubCategoryState());
  }

  int? mainCategoryId;
  String? mainCategory;
  int? subCategoryId;
  String? subCategory;

  void changeCategoryState() {
    emit(SelectCategoryState());
  }
}
