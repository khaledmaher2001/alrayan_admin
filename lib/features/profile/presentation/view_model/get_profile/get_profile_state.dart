import 'package:alrayan_admin/features/profile/data/model/profile_model/profile_model.dart';

sealed class GetProfileStates {}

final class GetProfileInitialState extends GetProfileStates {}

final class GetProfileLoadingState extends GetProfileStates {}

final class GetProfileSuccessState extends GetProfileStates {
  final ProfileModel model;

  GetProfileSuccessState(this.model);
}

final class GetProfileErrorState extends GetProfileStates {
  final String error;

  GetProfileErrorState(this.error);
}


