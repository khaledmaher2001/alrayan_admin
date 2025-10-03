import 'package:alrayan_admin/features/zones/data/repo/zones_repo.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/add_zone/add_zone_state.dart';
import 'package:bloc/bloc.dart';

class AddZoneCubit extends Cubit<AddZoneStates> {
  AddZoneCubit(this.productsRepo) : super(AddZoneInitialState());
  ZonesRepo? productsRepo;

  Future<void> addZone({required Map<String,dynamic> data}) async {
    emit(AddZoneLoadingState());

    var result = await productsRepo!.addZone(data: data);
    return result.fold(
      (failure) {
        emit(AddZoneErrorState(failure.errMessage));
      },
      (data) {
        emit(AddZoneSuccessState(data));
      },
    );
  }
}
