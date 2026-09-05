import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/home/data/models/inventory_analytics_model.dart';
import 'package:alrayan_admin/features/home/data/models/low_stock_config_model.dart';
import 'package:alrayan_admin/features/home/data/models/low_stock_product_model.dart';
import 'package:alrayan_admin/features/home/data/models/sales_report_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class HomeRepo{
  Future<Either<Failure,HomeStatisticsModel>> getHomeStatistics();
  Future<Either<Failure, InventoryAnalyticsResponseModel>> getInventoryAnalytics({
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<Either<Failure, LowStockProductsResponseModel>> getLowStockProducts({
    int? threshold,
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<Either<Failure, LowStockConfigModel>> getLowStockConfig();
  Future<Either<Failure, LowStockConfigModel>> updateLowStockConfig({
    required int threshold,
  });
  Future<Either<Failure, SalesReportModel>> getSalesReport({
    required String startDate,
    required String endDate,
    String type = '',
  });

}
