import 'package:alrayan_admin/features/categories/presentation/view_model/edit_sub_category/edit_sub_category_states.dart';
import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo.dart';

class EditSubCategoryCubit extends Cubit<EditSubCategoryStates> {
  EditSubCategoryCubit(this.categoriesRepo) : super(EditSubCategoryInitState());
  CategoriesRepo? categoriesRepo;

  Future<void> editSubCategory({required Map<String, dynamic> data, required int subCategoryId}) async {
    emit(EditSubCategoryLoadingState());
    var result = await categoriesRepo!.editSubCategory(data: data, subCategoryId: subCategoryId);
    return result.fold(
      (failure) {
        emit(EditSubCategoryErrorState(error: failure.errMessage));
      },
      (data) {
        emit(EditSubCategorySuccessState(message: data));
      },
    );
  }
}
