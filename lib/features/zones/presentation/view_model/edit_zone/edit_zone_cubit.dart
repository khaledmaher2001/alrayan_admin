import 'package:alrayan_admin/features/zones/data/repo/zones_repo.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/edit_zone/edit_zone_state.dart';
import 'package:bloc/bloc.dart';

class EditZoneCubit extends Cubit<EditZoneStates> {
  EditZoneCubit(this.productsRepo) : super(EditZoneInitialState());
  ZonesRepo? productsRepo;

  Future<void> editZone({required int zoneId, required Map<String, dynamic> data}) async {
    emit(EditZoneLoadingState());

    var result = await productsRepo!.editZone(zoneId: zoneId, data: data);
    return result.fold(
      (failure) {
        emit(EditZoneErrorState(failure.errMessage));
      },
      (data) {
        emit(EditZoneSuccessState(data));
      },
    );
  }
}
