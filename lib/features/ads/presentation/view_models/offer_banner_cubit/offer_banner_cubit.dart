import 'package:alrayan_admin/features/ads/data/models/offer_banner_model.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../../core/errors/failure.dart';
import '../../../data/repo/offer_banner/offer_banner_repo.dart';

part 'offer_banner_state.dart';

class OfferBannerCubit extends Cubit<OfferBannerState> {
  final OfferBannerRepo offerBannerRepo;

  OfferBannerCubit(this.offerBannerRepo) : super(OfferBannerInitial());

  List<Data> banner = [];
  int _currentIndex = 0;

  Future<void> fetchOfferBanners() async {
    emit(OfferBannerLoading());
    final Either<Failure, OfferBannerModel> result = await offerBannerRepo.getOfferBanner();
    result.fold(
          (failure) => emit(OfferBannerError(failure.errMessage)),
          (banners) {
        banner = banners.data!;
        emit(OfferBannerLoaded(banner, _currentIndex));
      },
    );
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    emit(OfferBannerLoaded(banner, _currentIndex));
  }
}

