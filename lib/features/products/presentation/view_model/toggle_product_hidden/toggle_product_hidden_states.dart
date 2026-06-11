abstract class ToggleProductHiddenStates {}

class ToggleProductHiddenInitState extends ToggleProductHiddenStates {}

class ToggleProductHiddenLoadingState extends ToggleProductHiddenStates {}

class ToggleProductHiddenSuccessState extends ToggleProductHiddenStates {}

class ToggleProductHiddenErrorState extends ToggleProductHiddenStates {
  final String error;
  ToggleProductHiddenErrorState(this.error);
}
