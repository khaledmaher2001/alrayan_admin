import 'package:alrayan_admin/features/ads/data/models/offer_banner_model.dart';
import 'package:alrayan_admin/features/ads/data/repo/ads/ads_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';

part 'offer_banner_state.dart';

class OfferBannerCubit extends Cubit<OfferBannerState> {
  final AdsRepo repo;

  OfferBannerCubit(this.repo) : super(OfferBannerInitial());

  List<Data> banner = [];
  int _currentIndex = 0;

  Future<void> fetchOfferBanners({bool withLoading = true}) async {
    if(withLoading){
      emit(OfferBannerLoading());
    }
    final Either<Failure, OfferBannerModel> result = await repo.getBanner();
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

