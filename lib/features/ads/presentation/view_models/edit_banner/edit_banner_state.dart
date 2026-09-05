part of 'edit_banner_cubit.dart';

@immutable
sealed class EditBannerState {}

final class EditBannerInitial extends EditBannerState {}

class EditBannerLoading extends EditBannerState {}

class EditBannerSuccess extends EditBannerState {
  final bool data;

  EditBannerSuccess(this.data);
}

class EditBannerError extends EditBannerState {
  final String error;
  EditBannerError(this.error);
}
