import 'package:alrayan_admin/features/categories/presentation/view_model/delete_category/delete_category_states.dart';
import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo.dart';

class DeleteCategoryCubit extends Cubit<DeleteCategoryStates> {
  DeleteCategoryCubit(this.categoriesRepo) : super(DeleteCategoryInitState());
  CategoriesRepo? categoriesRepo;

  Future<void> deleteCategory({required int categoryId}) async {
    emit(DeleteCategoryLoadingState());
    var result = await categoriesRepo!.deleteCategory(categoryId: categoryId);
    return result.fold(
      (failure) {
        emit(DeleteCategoryErrorState(error: failure.errMessage));
      },
      (data) {
        emit(DeleteCategorySuccessState(message: data));
      },
    );
  }
}
