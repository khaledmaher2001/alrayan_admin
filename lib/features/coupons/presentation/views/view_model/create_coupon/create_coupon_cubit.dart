import 'package:alrayan_admin/features/categories/presentation/view_model/edit_category/edit_category_states.dart';
import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo.dart';

class EditCategoryCubit extends Cubit<EditCategoryStates> {
  EditCategoryCubit(this.categoriesRepo) : super(EditCategoryInitState());
  CategoriesRepo? categoriesRepo;

  Future<void> editCategory({required Map<String, dynamic> data,required int categoryId}) async {
    emit(EditCategoryLoadingState());
    var result = await categoriesRepo!.editCategory(data: data,categoryId: categoryId);
    return result.fold(
      (failure) {
        emit(EditCategoryErrorState(error: failure.errMessage));
      },
      (data) {
        emit(EditCategorySuccessState(message: data));
      },
    );
  }
}
