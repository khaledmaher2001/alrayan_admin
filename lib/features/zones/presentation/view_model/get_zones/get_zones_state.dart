import 'package:alrayan_admin/features/zones/data/models/zones_model.dart';

sealed class GetZonesStates {}

final class GetZonesInitialState extends GetZonesStates {}

final class GetZonesLoadingState extends GetZonesStates {}

final class GetZonesSuccessState extends GetZonesStates {
  final ZonesModel model;

  GetZonesSuccessState(this.model);
}

final class GetZonesErrorState extends GetZonesStates {
  final String error;

  GetZonesErrorState(this.error);
}


