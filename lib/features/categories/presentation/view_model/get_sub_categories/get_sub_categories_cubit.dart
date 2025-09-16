import 'package:alrayan_admin/features/categories/presentation/view_model/get_sub_categories/get_sub_categories_states.dart';
import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo.dart';

class GetSubCategoriesCubit extends Cubit<GetSubCategoriesStates> {
  GetSubCategoriesCubit(this.categoriesRepo) : super(GetSubCategoriesInitState());
  CategoriesRepo? categoriesRepo;

  Future<void> getSubCategories({required int mainCategoryId}) async {
    emit(GetSubCategoriesLoadingState());
    var result = await categoriesRepo!.getSubCategories(mainCategoryId: mainCategoryId);
    return result.fold(
      (failure) {
        emit(GetSubCategoriesErrorState());
      },
      (data) {
        emit(GetSubCategoriesSuccessState(subCategoriesModel: data));
      },
    );
  }
}
