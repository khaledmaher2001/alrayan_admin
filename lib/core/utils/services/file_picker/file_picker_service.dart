import 'dart:io';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../extensions/chat_file_type_extension.dart';
import 'i_file_picker_service.dart';
import 'picked_file_model.dart';

class FilePickerService implements IFilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Future<PickedFileModel?> pickImageFromCamera() async {
    try {
      final XFile? picked =
          await _imagePicker.pickImage(source: ImageSource.camera);
      return _toPickedFileModel(picked?.path);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PickedFileModel?> pickImageFromGallery() async {
    final XFile? picked =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    return _toPickedFileModel(picked?.path);
  }

  /// this function is used to pick any file from device
  @override
  Future<PickedFileModel?> pickAnyFile(
      {List<String>? allowedExtensions}) async {
    final result = await file_picker.FilePicker.platform.pickFiles(
      type: allowedExtensions != null
          ? file_picker.FileType.custom
          : file_picker.FileType.any,
      allowedExtensions: allowedExtensions,
    );

    final file = result?.files.single;
    if (file == null || file.path == null) return null;

    return _toPickedFileModel(file.path!);
  }

  /// this function is used to convert the file path to [PickedFileModel]
  PickedFileModel? _toPickedFileModel(String? filePath) {
    if (filePath == null) return null;

    final file = File(filePath);
    final extension =
        path.extension(file.path).replaceFirst('.', '').toLowerCase();
    final fileName = path.basename(file.path);
    final fileType = ChatFileTypeExtension.fromExtension(extension);

    return PickedFileModel(
      file: file,
      fileName: fileName,
      extension: extension,
      type: fileType,
    );
  }
}
