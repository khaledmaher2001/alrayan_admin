import 'picked_file_model.dart';

/// this service is responsible for picking files from device
/// it is used to handle camera and gallery pickers
/// and return the picked file path, type and name in [PickedFileModel]
abstract class IFilePickerService {
  Future<PickedFileModel?> pickImageFromCamera();
  Future<PickedFileModel?> pickImageFromGallery();
  Future<PickedFileModel?> pickAnyFile({List<String>? allowedExtensions});
}
