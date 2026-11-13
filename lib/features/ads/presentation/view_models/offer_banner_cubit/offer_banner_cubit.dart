import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';
import 'package:alrayan_admin/features/ads/data/models/offer_banner_model.dart';
import 'package:alrayan_admin/features/ads/data/repo/ads/ads_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';

part 'offer_banner_state.dart';

class OfferBannerCubit extends Cubit<OfferBannerState> with RequestGuardMixin {
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

    final reqId = beginRequest();
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
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;
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
    if (!hasMore || isLoadingMore || isClosed) return;
    isLoadingMore = true;
    page++;
    try {
      await fetchOfferBanners(withLoading: false);
    } finally {
      if (!isClosed) isLoadingMore = false;
    }
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    emit(OfferBannerLoaded(banner, _currentIndex));
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}

