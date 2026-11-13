part of 'set_spins_cubit.dart';

abstract class SetSpinsState {}

class SetSpinsInitial extends SetSpinsState {}

class SetSpinsLoadingState extends SetSpinsState {
  final int userId;
  SetSpinsLoadingState(this.userId);
}

class SetSpinsSuccessState extends SetSpinsState {
  final int userId;
  final int attemptCount;
  SetSpinsSuccessState(this.userId, this.attemptCount);
}

class SetSpinsErrorState extends SetSpinsState {
  final String error;
  SetSpinsErrorState(this.error);
}
