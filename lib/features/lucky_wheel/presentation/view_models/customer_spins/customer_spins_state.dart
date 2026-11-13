part of 'customer_spins_cubit.dart';

abstract class CustomerSpinsState {}

class CustomerSpinsInitial extends CustomerSpinsState {}

class CustomerSpinsLoadingState extends CustomerSpinsState {}

class CustomerSpinsSuccessState extends CustomerSpinsState {}

class CustomerSpinsErrorState extends CustomerSpinsState {
  final String error;
  CustomerSpinsErrorState(this.error);
}
