
import '../../../data/models/home_statistics_model.dart';
import '../../../data/models/inventory_analytics_model.dart';
import '../../../data/models/low_stock_product_model.dart';
import '../../../data/models/sales_report_model.dart';

abstract class GetHomeStatisticsStates {}

class GetHomeStatisticsInitState extends GetHomeStatisticsStates {}

class GetHomeStatisticsLoadingState extends GetHomeStatisticsStates {}

class GetHomeStatisticsSuccessState extends GetHomeStatisticsStates {
  final HomeStatisticsModel model;
  final List<InventoryAnalyticsModel> inventoryAnalytics;
  final List<LowStockProductModel> lowStockProducts;
  final int? lowStockProductsTotal;
  final SalesReportModel? salesReport;
  final String? inventoryAnalyticsError;
  final String? lowStockProductsError;
  final String? salesReportError;

  GetHomeStatisticsSuccessState({
    required this.model,
    this.inventoryAnalytics = const [],
    this.lowStockProducts = const [],
    this.lowStockProductsTotal,
    this.salesReport,
    this.inventoryAnalyticsError,
    this.lowStockProductsError,
    this.salesReportError,
  });
}

class GetHomeStatisticsErrorState extends GetHomeStatisticsStates {}
