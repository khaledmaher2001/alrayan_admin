import 'package:alrayan_admin/features/profile/data/repo/profile_repo/profile_repo.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_state.dart';
import 'package:bloc/bloc.dart';

class GetProfileCubit extends Cubit<GetProfileStates> {
  GetProfileCubit(this.productsRepo) : super(GetProfileInitialState());
  ProfileRepo? productsRepo;

  Future<void> getProfile() async {
    emit(GetProfileLoadingState());

    var result = await productsRepo!.getProfile();
    return result.fold(
      (failure) {
        emit(GetProfileErrorState(failure.errMessage));
      },
      (data) {
        emit(GetProfileSuccessState(data));
      },
    );
  }
}
