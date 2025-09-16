import 'package:alrayan_admin/features/categories/presentation/view_model/delete_sub_category/delete_sub_category_states.dart';
import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo.dart';

class DeleteSubCategoryCubit extends Cubit<DeleteSubCategoryStates> {
  DeleteSubCategoryCubit(this.categoriesRepo) : super(DeleteSubCategoryInitState());
  CategoriesRepo? categoriesRepo;

  Future<void> deleteSubCategory({required int subCategoryId}) async {
    emit(DeleteSubCategoryLoadingState());
    var result = await categoriesRepo!.deleteSubCategory(subCategoryId: subCategoryId);
    return result.fold(
      (failure) {
        emit(DeleteSubCategoryErrorState(error: failure.errMessage));
      },
      (data) {
        emit(DeleteSubCategorySuccessState(message: data));
      },
    );
  }
}
