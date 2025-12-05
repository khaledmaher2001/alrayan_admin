import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/services/file_picker/i_file_picker_service.dart';
import '../../utils/services/file_picker/picked_file_model.dart';

part 'file_picker_state.dart';

class FilePickerCubit extends Cubit<FilePickerState> {
  final IFilePickerService filePickerService;

  static FilePickerCubit get(BuildContext context) =>
      context.read<FilePickerCubit>();

  FilePickerCubit(this.filePickerService) : super(FilePickerInitial());

  Future<PickedFileModel?> pickFromGallery() async {
    emit(FilePickerLoading());
    final file = await filePickerService.pickImageFromGallery();
    file != null ? emit(FilePickerSuccess(file)) : emit(FilePickerCancelled());
    return file;
  }

  Future<PickedFileModel?> pickFromCamera() async {
    emit(FilePickerLoading());
    final file = await filePickerService.pickImageFromCamera();
    file != null ? emit(FilePickerSuccess(file)) : emit(FilePickerCancelled());
    return file;
  }

  Future<PickedFileModel?> pickAnyFile({List<String>? extensions}) async {
    emit(FilePickerLoading());
    final file =
        await filePickerService.pickAnyFile(allowedExtensions: extensions);
    file != null ? emit(FilePickerSuccess(file)) : emit(FilePickerCancelled());
    return file;
  }

  void reset() => emit(FilePickerInitial());
}
