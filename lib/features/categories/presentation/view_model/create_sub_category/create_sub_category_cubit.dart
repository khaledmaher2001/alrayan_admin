import 'dart:io';

import 'package:alrayan_admin/features/categories/presentation/view_model/create_category/create_category_states.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/create_sub_category/create_sub_category_states.dart';
import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo.dart';
import 'package:image_picker/image_picker.dart';

class CreateSubCategoryCubit extends Cubit<CreateSubCategoryStates> {
  CreateSubCategoryCubit(this.categoriesRepo) : super(CreateSubCategoryInitState());
  CategoriesRepo? categoriesRepo;

  Future<void> createSubCategory({required Map<String, dynamic> data}) async {
    emit(CreateSubCategoryLoadingState());
    var result = await categoriesRepo!.createSubCategory(data: data);
    return result.fold(
      (failure) {
        emit(CreateSubCategoryErrorState(error: failure.errMessage));
      },
      (data) {
        emit(CreateSubCategorySuccessState(message: data));
      },
    );
  }

  File? subCategoryIcon;
  ImagePicker picker = ImagePicker();

  Future<void> selectSubCategoryIcon() async {
    await picker.pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        subCategoryIcon = File(value.path);
        emit(SelectSubCategoryIconState());
      }
    });
  }
}
