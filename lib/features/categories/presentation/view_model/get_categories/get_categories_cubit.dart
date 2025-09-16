import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';
import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_states.dart';

class GetCategoriesCubit extends Cubit<GetCategoriesStates> {
  GetCategoriesCubit(this.categoriesRepo) : super(GetCategoriesInitState());
  CategoriesRepo? categoriesRepo;

  CategoriesModel? categoriesModel;
  Future<void> getCategories() async {
    emit(GetCategoriesLoadingState());
    var result = await categoriesRepo!.getCategories();
    return result.fold((failure) {
      emit(GetCategoriesErrorState());
    }, (data) {
      categoriesModel=data;
      emit(GetCategoriesSuccessState(categoriesModel: data));
    });
  }
}
