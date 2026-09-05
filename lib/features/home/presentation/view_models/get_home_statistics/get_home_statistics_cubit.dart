import 'package:bloc/bloc.dart';

import '../../../data/models/home_statistics_model.dart';
import '../../../data/models/inventory_analytics_model.dart';
import '../../../data/models/low_stock_product_model.dart';
import '../../../data/models/sales_report_model.dart';
import '../../../data/repo/home_repo.dart';
import 'get_home_statistics_states.dart';

class GetHomeStatisticsCubit extends Cubit<GetHomeStatisticsStates> {
  GetHomeStatisticsCubit(this.repo) : super(GetHomeStatisticsInitState());
  HomeRepo? repo;

  HomeStatisticsModel? ordersModel;
  List<InventoryAnalyticsModel> inventoryAnalytics = [];
  List<LowStockProductModel> lowStockProducts = [];
  int? lowStockProductsTotal;
  SalesReportModel? salesReport;

  Future<void> getHomeStatistics({String? status, bool withLoading = true}) async {
    if (withLoading) {
      emit(GetHomeStatisticsLoadingState());
    }
    var result = await repo!.getHomeStatistics();
    return result.fold(
      (failure) {
        emit(GetHomeStatisticsErrorState());
      },
      (data) async {
        ordersModel = data;

        String? inventoryAnalyticsError;
        String? lowStockProductsError;
        String? salesReportError;

        final now = DateTime.now();
        final startDate = DateTime(now.year, now.month - 1, now.day)
            .toIso8601String()
            .split('T')
            .first;
        final endDate = now.toIso8601String().split('T').first;

        final inventoryResult = await repo!.getInventoryAnalytics();
        inventoryResult.fold(
          (failure) => inventoryAnalyticsError = failure.errMessage,
          (data) => inventoryAnalytics = data.items,
        );

        final lowStockResult = await repo!.getLowStockProducts();
        lowStockResult.fold(
          (failure) => lowStockProductsError = failure.errMessage,
          (data) {
            lowStockProducts = data.items;
            // The server reports the real total via metadata, so the
            // dashboard badge doesn't need to over-fetch to stay accurate.
            lowStockProductsTotal =
                data.metadata?.totalItems ?? data.items.length;
          },
        );

        final salesReportResult = await repo!.getSalesReport(
          startDate: startDate,
          endDate: endDate,
        );
        salesReportResult.fold(
          (failure) => salesReportError = failure.errMessage,
          (data) => salesReport = data,
        );

        emit(GetHomeStatisticsSuccessState(
          model: data,
          inventoryAnalytics: inventoryAnalytics,
          lowStockProducts: lowStockProducts,
          lowStockProductsTotal: lowStockProductsTotal,
          salesReport: salesReport,
          inventoryAnalyticsError: inventoryAnalyticsError,
          lowStockProductsError: lowStockProductsError,
          salesReportError: salesReportError,
        ));
      },
    );
  }
}
