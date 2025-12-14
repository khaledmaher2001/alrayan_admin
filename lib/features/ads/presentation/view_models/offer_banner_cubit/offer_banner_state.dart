part of 'offer_banner_cubit.dart';

abstract class OfferBannerState {}

class OfferBannerInitial extends OfferBannerState {}

class OfferBannerLoading extends OfferBannerState {}

class OfferBannerError extends OfferBannerState {
  final String message;
  OfferBannerError(this.message);
}

class OfferBannerLoaded extends OfferBannerState {
  final List<Data> banners;
  final int currentIndex;

  OfferBannerLoaded(this.banners, [this.currentIndex = 0]);
}
