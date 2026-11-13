import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';
import '../../../data/models/lucky_wheel_model.dart';
import '../../../data/repo/luck_wheel_repo.dart';

part 'get_lucky_wheel_items_state.dart';

class GetLuckyWheelItemsCubit extends Cubit<GetLuckyWheelItemsState>
    with RequestGuardMixin {
  GetLuckyWheelItemsCubit(this.repo) : super(GetLuckyWheelItemsInitial());

  LuckyWheelRepo repo;

  LuckyWheelModel? luckyWheelModel;
  List<Rewards> luckyWheelList = [];
  int page = 1;

  Future<void> getLuckyWheelItems({bool withLoading = true}) async {
    final reqId = beginRequest();
    if (withLoading) {
      luckyWheelList.clear();
      luckyWheelModel = null;
      page = 1;
      emit(GetLuckyWheelItemsLoadingState());
    }

    final result =
        await repo.getLuckyWheelItems(cancelToken: requestCancelToken);
    if (!isCurrentRequest(reqId)) return;
    result.fold(
      (failure) {
        emit(GetLuckyWheelItemsErrorState(failure.errMessage));
      },
      (data) {
        luckyWheelModel = data;
        luckyWheelList = List<Rewards>.from(data.data?.rewards ?? []);
        emit(GetLuckyWheelItemsSuccessState(data));
      },
    );
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }

  Future<void> toggleSpinWheel() async {
    emit(GetLuckyWheelToggleLoadingState());
    final result = await repo.toggleSpinWheel();
    result.fold(
      (failure) => emit(GetLuckyWheelToggleErrorState(failure.errMessage)),
      (_) => getLuckyWheelItems(withLoading: false),
    );
  }

  /// "Lucky time" on/off: whether orders placed now earn spins (customers with
  /// saved spins can spin either way). Explicit value, so a double tap can't
  /// flip it back. Turning it on notifies all customers (server side).
  Future<void> setLuckyTime(bool on) async {
    emit(GetLuckyWheelToggleLoadingState());
    final result = await repo.updateSpinConfig(earningOpen: on);
    if (isClosed) return;
    result.fold(
      (failure) => emit(GetLuckyWheelToggleErrorState(failure.errMessage)),
      (config) {
        luckyWheelModel?.data?.isActive = config.earningOpen;
        luckyWheelModel?.data?.orderRules = config.orderRules;
        emit(GetLuckyWheelLuckyTimeChangedState(config.earningOpen));
        getLuckyWheelItems(withLoading: false);
      },
    );
  }

  double get totalProbability {
    if (luckyWheelList.isEmpty) return 0.0;
    return luckyWheelList.fold(0.0, (sum, item) {
      final p = (item.probability is num) ? (item.probability as num).toDouble() : 0.0;
      return sum + p;
    });
  }
}
