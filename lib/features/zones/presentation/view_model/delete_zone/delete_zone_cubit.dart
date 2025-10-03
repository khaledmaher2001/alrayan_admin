import 'package:alrayan_admin/features/zones/data/repo/zones_repo.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/delete_zone/delete_zone_state.dart';
import 'package:bloc/bloc.dart';

class DeleteZoneCubit extends Cubit<DeleteZoneStates> {
  DeleteZoneCubit(this.productsRepo) : super(DeleteZoneInitialState());
  ZonesRepo? productsRepo;

  Future<void> deleteZone({required int zoneId}) async {
    emit(DeleteZoneLoadingState());

    var result = await productsRepo!.deleteZone(zoneId: zoneId);
    return result.fold(
      (failure) {
        emit(DeleteZoneErrorState(failure.errMessage));
      },
      (data) {
        emit(DeleteZoneSuccessState(data));
      },
    );
  }

  int selectedZoneId=-1;

  void selectZone(int id){
    selectedZoneId=id;
    emit(SelectZoneState());
  }
}
