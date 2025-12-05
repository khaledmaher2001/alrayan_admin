import 'dart:convert';
import 'dart:typed_data';

import '../services/file_picker/picked_file_model.dart';

extension PickedFileModelExtensions on PickedFileModel {
  /// Returns the file content as base64 string.
  Future<String> toBase64() async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Returns the file content as bytes.
  Future<Uint8List> toBytes() async => await file.readAsBytes();
}
