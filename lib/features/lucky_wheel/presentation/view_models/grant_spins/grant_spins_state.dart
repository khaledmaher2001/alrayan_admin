part of 'grant_spins_cubit.dart';

abstract class GrantSpinsState {}

class GrantSpinsInitial extends GrantSpinsState {}

class GrantSpinsLoadingState extends GrantSpinsState {}

class GrantSpinsSuccessState extends GrantSpinsState {
  final int customers;
  GrantSpinsSuccessState(this.customers);
}

class GrantSpinsErrorState extends GrantSpinsState {
  final String error;
  GrantSpinsErrorState(this.error);
}
