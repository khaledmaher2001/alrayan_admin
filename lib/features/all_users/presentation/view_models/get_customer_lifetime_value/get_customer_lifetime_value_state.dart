import 'package:alrayan_admin/features/all_users/data/models/customer_lifetime_value_model.dart';

abstract class GetCustomerLifetimeValueState {}

class GetCustomerLifetimeValueInitial extends GetCustomerLifetimeValueState {}

class GetCustomerLifetimeValueLoading extends GetCustomerLifetimeValueState {}

class GetCustomerLifetimeValueSuccess extends GetCustomerLifetimeValueState {
  final CustomerLifetimeValueModel data;
  GetCustomerLifetimeValueSuccess(this.data);
}

class GetCustomerLifetimeValueError extends GetCustomerLifetimeValueState {
  final String message;
  GetCustomerLifetimeValueError(this.message);
}
