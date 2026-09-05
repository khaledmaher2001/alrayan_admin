import 'package:alrayan_admin/features/home/data/models/sales_report_model.dart';

abstract class GetSalesReportState {}

class GetSalesReportInitial extends GetSalesReportState {}

class GetSalesReportLoading extends GetSalesReportState {}

class GetSalesReportSuccess extends GetSalesReportState {
  final SalesReportModel report;
  GetSalesReportSuccess(this.report);
}

class GetSalesReportError extends GetSalesReportState {
  final String message;
  GetSalesReportError(this.message);
}
