import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_states.dart';

class SelectProductPhotosCubit extends Cubit<SelectProductPhotosStates> {
  SelectProductPhotosCubit() : super(SelectProductPhotosInitState());

  int? mainCategoryId;
  String? mainCategory;

  int? subCategoryId;
  String? subCategory;

  List<File> productPhotos = [];
  ImagePicker picker = ImagePicker();

  int photoIndex = 0;

  void setInitialCategory({
    required int? mainId,
    required String? mainName,
    required int? subId,
    required String? subName,
  }) {
    mainCategoryId = mainId;
    mainCategory = mainName;

    subCategoryId = subId;
    subCategory = subName;

    emit(ChangeProductCategoryState());
  }

  void changeMainCategory({
    required int? id,
    required String? name,
  }) {
    mainCategoryId = id;
    mainCategory = name;

    // مهم جدًا: لما الصنف الرئيسي يتغير لازم نمسح الصنف الفرعي القديم
    subCategoryId = null;
    subCategory = null;

    emit(ChangeProductCategoryState());
  }

  void changeSubCategory({
    required int? id,
    required String? name,
  }) {
    subCategoryId = id;
    subCategory = name;

    emit(ChangeProductCategoryState());
  }

  Future<void> selectProductPhotos() async {
    final photos = await picker.pickMultiImage(limit: 5);

    if (photos.isNotEmpty) {
      for (int i = 0; i < photos.length; i++) {
        if (productPhotos.length < 5) {
          productPhotos.add(File(photos[i].path));
        }
      }

      emit(SelectProductPhotosState());
    }
  }

  void removeProductPhotoAt(int index) {
    if (index >= 0 && index < productPhotos.length) {
      productPhotos.removeAt(index);
      emit(RemoveProductPhotosState());
    }
  }

  void removeProductPhotos() {
    emit(RemoveProductPhotosState());
  }

  void clearProductPhotos() {
    productPhotos.clear();
    emit(RemoveProductPhotosState());
  }

  void selectPhotoIndex(int index) {
    photoIndex = index;
    emit(RemoveProductPhotosState());
  }
}