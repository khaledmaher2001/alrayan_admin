import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';

import '../../../data/models/all_users_model.dart';

abstract class GetAllUsersStates {}

class GetAllUsersInitState extends GetAllUsersStates {}

class GetAllUsersLoadingState extends GetAllUsersStates {}

class GetAllUsersSuccessState extends GetAllUsersStates {
  final AllUsersModel model;

  GetAllUsersSuccessState({required this.model});
}

class GetAllUsersErrorState extends GetAllUsersStates {}
