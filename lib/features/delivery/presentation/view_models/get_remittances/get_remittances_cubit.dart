import 'package:bloc/bloc.dart';

import '../../../data/models/remittance_model.dart';
import '../../../data/repo/delivery_repo.dart';
import 'get_remittances_states.dart';

class GetRemittancesCubit extends Cubit<GetRemittancesStates> {
  GetRemittancesCubit(this.repo) : super(GetRemittancesInitState());

  final DeliveryRepo repo;

  List<Remittance> remittancesList = [];
  RemittancesModel? remittancesModel;
  int page = 1;
  String? status;
  int? courierId;
  String sortBy = 'createdAt';
  String sortOrder = 'DESC';

  Future<void> getRemittances({bool withLoading = true}) async {
    if (withLoading) {
      remittancesModel = null;
      remittancesList.clear();
      page = 1;
      emit(GetRemittancesLoadingState());
    }

    final result = await repo.getRemittances(
      data: {
        'page': page,
        'limit': 15,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (status != null) 'status': status,
        if (courierId != null) 'courierId': courierId,
      },
    );

    result.fold(
      (failure) => emit(GetRemittancesErrorState(failure.errMessage)),
      (data) {
        remittancesModel = data;
        remittancesList = remittancesList + (data.data?.items ?? []);
        emit(GetRemittancesSuccessState(model: data));
      },
    );
  }

  void setFilters({String? status, int? courierId}) {
    this.status = status;
    this.courierId = courierId;
  }

  /// Re-fetches the first page after an approve/reject action so the list
  /// reflects the real server state, without emitting a loading state first
  /// — the list stays on screen as-is and only swaps once the fresh data
  /// arrives, instead of flashing a spinner.
  Future<void> refreshSilently() async {
    final result = await repo.getRemittances(
      data: {
        'page': 1,
        'limit': 15,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (status != null) 'status': status,
        if (courierId != null) 'courierId': courierId,
      },
    );

    result.fold((failure) {}, (data) {
      page = 1;
      remittancesModel = data;
      remittancesList = data.data?.items ?? [];
      emit(GetRemittancesSuccessState(model: data));
    });
  }
}
