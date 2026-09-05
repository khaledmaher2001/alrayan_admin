import '../../../data/models/release_log_model.dart';

abstract class GetReleaseLogsStates {}

class GetReleaseLogsInitState extends GetReleaseLogsStates {}

class GetReleaseLogsLoadingState extends GetReleaseLogsStates {}

class GetReleaseLogsSuccessState extends GetReleaseLogsStates {
  final ReleaseLogsModel model;

  GetReleaseLogsSuccessState({required this.model});
}

class GetReleaseLogsErrorState extends GetReleaseLogsStates {
  final String message;

  GetReleaseLogsErrorState(this.message);
}
