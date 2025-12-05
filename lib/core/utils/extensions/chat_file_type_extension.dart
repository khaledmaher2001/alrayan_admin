import '../services/file_picker/chat_file_type_enum.dart';

extension ChatFileTypeExtension on ChatFileType {
  String get extension => name;
  static ChatFileType? fromExtension(String ext) {
    try {
      return ChatFileType.values.firstWhere(
        (e) => e.name.toLowerCase() == ext.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
