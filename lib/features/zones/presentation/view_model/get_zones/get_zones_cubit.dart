import 'package:alrayan_admin/features/zones/data/repo/zones_repo.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/get_zones/get_zones_state.dart';
import 'package:bloc/bloc.dart';

class GetZonesCubit extends Cubit<GetZonesStates> {
  GetZonesCubit(this.productsRepo) : super(GetZonesInitialState());
  ZonesRepo? productsRepo;

  Future<void> getZones({bool withLoading=false}) async {
    if(withLoading){
      emit(GetZonesLoadingState());
    }

    var result = await productsRepo!.getZones();
    return result.fold(
      (failure) {
        emit(GetZonesErrorState(failure.errMessage));
      },
      (data) {
        emit(GetZonesSuccessState(data));
      },
    );
  }
}
