import 'dart:io';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/shared_cubit/file_picker_cubit/file_picker_cubit.dart';
import '../../../../../../core/shared_widgets/image_picker_dialog.dart';
import '../../../../../../core/utils/services/file_picker/picked_file_model.dart';

part 'ads_assets_state.dart';

class AdsAssetsCubit extends Cubit<AdsAssetsState> {
  AdsAssetsCubit() : super(AdsAssetsInitial());

  static AdsAssetsCubit get(context) => BlocProvider.of(context);

  File? newImage;
  bool _isFileTooLarge(File file, {int maxMB = 30}) {
    final fileSizeInBytes = file.lengthSync();
    return fileSizeInBytes > maxMB * 1024 * 1024;
  }

  Future selectNewImage(context) async {
    final fileCubit = FilePickerCubit.get(context);
    emit(SelectNewImageLoadingState());

    final source = await showImageSourceSelector(context);
    PickedFileModel? result;

    if (source == ImageSource.camera) {
      result = await fileCubit.pickFromCamera();
    } else if (source == ImageSource.gallery) {
      result = await fileCubit.pickFromGallery();
    }

    if (result != null) {
      if (_isFileTooLarge(result.file)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be less than 30 MB')),
        );
        return;
      }

      newImage = result.file;
      emit(SelectNewImageSuccessState(image: newImage));
    }
  }


  Future deleteNewImage() async {
    emit(DeleteNewImageLoadingState());
    newImage = null;
    emit(DeleteNewImageSuccessState());
  }
  String? adsType;
  void selectAdsType({required String type}) {
    adsType = type;
    emit(SelectAdsTypeSuccessState());
  }

  Items? selectedProduct;

  void selectProduct({required Items instance}) {
    selectedProduct = instance; // replace the previous selection
    emit(SelectAdsProductSuccessState());
  }

  void removeProduct() {
    selectedProduct = null; // deselect
    emit(SelectAdsProductSuccessState());
  }

}
