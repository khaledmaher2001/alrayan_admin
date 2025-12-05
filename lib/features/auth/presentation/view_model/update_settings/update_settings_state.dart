
import '../../../data/models/register_model.dart';
import '../../../data/models/update_settings_model.dart';

abstract class UpdateSettingsStates {}

final class UpdateSettingsInitialState extends UpdateSettingsStates {}

final class UpdateSettingsLoadingState extends UpdateSettingsStates {}

final class UpdateSettingsSuccessState extends UpdateSettingsStates {
  final UpdateSettingsModel updateModel;

  UpdateSettingsSuccessState(this.updateModel);
}

final class UpdateSettingsErrorState extends UpdateSettingsStates {
  final String errorMessage;

  UpdateSettingsErrorState(this.errorMessage);
}
