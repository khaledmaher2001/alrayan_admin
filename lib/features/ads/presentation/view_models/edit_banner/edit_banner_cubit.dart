import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../data/repo/ads/ads_repo.dart';

part 'edit_banner_state.dart';

class EditBannerCubit extends Cubit<EditBannerState> {
  AdsRepo adsRepo;

  EditBannerCubit(this.adsRepo) : super(EditBannerInitial());
  double? progress;

  Future<void> updateBanner({required int id, required var data}) async {
    progress = 0;
    emit(EditBannerLoading());
    final result = await adsRepo.updateBanner(
      id: id,
      data: data,
      onSendProgress: (a, b) {
        progress = a / b;
        emit(EditBannerLoading());
      },
    );
    try {
      result.fold(
        (failure) {
          emit(EditBannerError(failure.errMessage));
        },
        (data) {
          emit(EditBannerSuccess(data));
        },
      );
    } catch (e) {
      emit(EditBannerError(e.toString()));
    }
  }
}
