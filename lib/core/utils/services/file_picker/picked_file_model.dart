import 'dart:io';

import 'chat_file_type_enum.dart';

/// this model is used to represent the file that is picked by the user
/// it contain the file it self, the name of the file, the type of the file and the extension of the file
class PickedFileModel {
  final File file;
  final String fileName;
  final ChatFileType? type;
  final String extension;

  PickedFileModel({
    required this.file,
    required this.fileName,
    required this.extension,
    required this.type,
  });
  String get path => file.path;
  bool get isImage =>
      ['jpg', 'jpeg', 'png', 'gif'].contains(extension.replaceAll('.', ''));
}
