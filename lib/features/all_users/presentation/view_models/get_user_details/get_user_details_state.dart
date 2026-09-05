import 'package:alrayan_admin/features/all_users/data/models/user_detail_model.dart';

abstract class GetUserDetailsState {}

class GetUserDetailsInitial extends GetUserDetailsState {}

class GetUserDetailsLoading extends GetUserDetailsState {}

class GetUserDetailsSuccess extends GetUserDetailsState {
  final UserDetailModel user;
  GetUserDetailsSuccess(this.user);
}

class GetUserDetailsError extends GetUserDetailsState {
  final String message;
  GetUserDetailsError(this.message);
}
