import 'package:bloc/bloc.dart';
import '../../../data/repo/ads/ads_repo.dart';

part 'delete_banner_state.dart';

class DeleteBannersCubit extends Cubit<DeleteBannersState> {
  final AdsRepo repo;

  DeleteBannersCubit(this.repo) : super(DeleteBannersInitial());

  int selectedBanner=-1;
  Future<void> deleteBanner({required int id}) async {
    emit(DeleteBannersLoading());
    final result = await repo.deleteBanner(id: id);
    result.fold((failure) => emit(DeleteBannersError(failure.errMessage)), (data) {
      emit(DeleteBannersLoaded(data));
    });
  }
}
