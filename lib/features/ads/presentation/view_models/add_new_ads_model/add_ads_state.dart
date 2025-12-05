part of 'add_ads_cubit.dart';

@immutable
sealed class AddAdsState {}

final class AddAdsInitial extends AddAdsState {}

//complete info states
class AddAdsLoading extends AddAdsState {}

class AddAdsSuccess extends AddAdsState {
  final bool data;

  AddAdsSuccess(this.data);
}

class AddAdsError extends AddAdsState {
  final String error;
  AddAdsError(this.error);
}
