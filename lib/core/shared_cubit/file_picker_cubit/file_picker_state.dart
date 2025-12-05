part of 'file_picker_cubit.dart';

@immutable
sealed class FilePickerState {}

final class FilePickerInitial extends FilePickerState {}

class FilePickerLoading extends FilePickerState {}

class FilePickerSuccess extends FilePickerState {
  final PickedFileModel file;
  FilePickerSuccess(this.file);
}

class FilePickerCancelled extends FilePickerState {}
