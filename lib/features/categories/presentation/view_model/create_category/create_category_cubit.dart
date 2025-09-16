import 'dart:io';

import 'package:alrayan_admin/features/categories/presentation/view_model/create_category/create_category_states.dart';
import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo.dart';
import 'package:image_picker/image_picker.dart';

class CreateCategoryCubit extends Cubit<CreateCategoryStates> {
  CreateCategoryCubit(this.categoriesRepo) : super(CreateCategoryInitState());
  CategoriesRepo? categoriesRepo;

  Future<void> createCategory({required Map<String, dynamic> data}) async {
    emit(CreateCategoryLoadingState());
    var result = await categoriesRepo!.createCategory(data: data);
    return result.fold(
      (failure) {
        emit(CreateCategoryErrorState(error: failure.errMessage));
      },
      (data) {
        emit(CreateCategorySuccessState(message: data));
      },
    );
  }

  File? categoryIcon;
  ImagePicker picker = ImagePicker();

  Future<void> selectCategoryIcon() async {
    await picker.pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        categoryIcon = File(value.path);
        emit(SelectCategoryIconState());
      }
    });
  }
}
