import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_states.dart';
import 'package:bloc/bloc.dart';

class SelectProductPhotosCubit extends Cubit<SelectProductPhotosStates> {
  SelectProductPhotosCubit() : super(SelectProductPhotosInitState());


  int? mainCategoryId;
  String? mainCategory;
  int? subCategoryId;
  String? subCategory;

  List<File> productPhotos = [];
  ImagePicker picker = ImagePicker();

  Future<void> selectProductPhotos() async {
    await picker.pickMultiImage(limit: 5).then((photos) {
      if (photos.isNotEmpty) {
        for (int i = 0; i < photos.length; i++) {
          if (productPhotos.length < 5) {
            productPhotos.add(File(photos[i].path));
          }
        }
        emit(SelectProductPhotosState());
      }
    });
  }

  void removeProductPhotos() {
    emit(RemoveProductPhotosState());
  }



 int photoIndex=0;

  void selectPhotoIndex(int index) {
    photoIndex=index;
    emit(RemoveProductPhotosState());
  }
}
