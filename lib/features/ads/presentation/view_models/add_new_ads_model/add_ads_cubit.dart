import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../data/repo/ads/ads_repo.dart';

part 'add_ads_state.dart';

class AddAdsCubit extends Cubit<AddAdsState> {
  AdsRepo addAdsRepo;

  AddAdsCubit(this.addAdsRepo) : super(AddAdsInitial());
  double? progress;

  Future<void> addAds({required var data}) async {
    progress = 0;
    emit(AddAdsLoading());
    final result = await addAdsRepo.addAds(
      data: data,
      onSendProgress: (a, b) {
        progress = a / b;
        emit(AddAdsLoading());
      },
    );
    try {
      result.fold(
        (failure) {
          emit(AddAdsError(failure.errMessage));
        },
        (data) {
          emit(AddAdsSuccess(data));
        },
      );
    } catch (e) {
      emit(AddAdsError(e.toString()));
    }
  }
}
