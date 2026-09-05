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
  final Set<int> _loadedIds = {};
  int _currentIndex = 0;

  int page = 1;
  final int limit = 10;
  bool hasMore = true;
  bool isLoadingMore = false;
  String search = '';

  Future<void> fetchOfferBanners({
    bool withLoading = true,
    String? search,
  }) async {
    if (search != null) {
      this.search = search.trim();
    }

    if (withLoading) {
      page = 1;
      hasMore = true;
      banner.clear();
      _loadedIds.clear();
      emit(OfferBannerLoading());
    }

    final Either<Failure, OfferBannerModel> result = await repo.getBanner(
      page: page,
      limit: limit,
      search: this.search.isEmpty ? null : this.search,
    );
    result.fold(
          (failure) => emit(OfferBannerError(failure.errMessage)),
          (banners) {
        final items = banners.data ?? [];
        final newItems = items
            .where((item) => item.id == null || _loadedIds.add(item.id!))
            .toList();

        banner.addAll(newItems);
        hasMore = banners.links?.hasNext ??
            (items.length >= limit && newItems.isNotEmpty);
        emit(OfferBannerLoaded(banner, _currentIndex));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;
    page++;
    await fetchOfferBanners(withLoading: false);
    isLoadingMore = false;
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    emit(OfferBannerLoaded(banner, _currentIndex));
  }
}

