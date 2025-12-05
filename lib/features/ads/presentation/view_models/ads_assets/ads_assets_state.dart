part of 'ads_assets_cubit.dart';

@immutable
abstract class AdsAssetsState {}

class AdsAssetsInitial extends AdsAssetsState {}



class SelectNewImageLoadingState extends AdsAssetsState {}

class SelectNewImageSuccessState extends AdsAssetsState {
  final File? image;

  SelectNewImageSuccessState({required this.image});
}



class DeleteNewImageLoadingState extends AdsAssetsState {}

class DeleteNewImageSuccessState extends AdsAssetsState {}
class SelectAdsTypeSuccessState extends AdsAssetsState {}
class SelectAdsProductSuccessState extends AdsAssetsState {}
