import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';

import '../../../data/models/home_statistics_model.dart';
import '../../../data/models/inventory_analytics_model.dart';
import '../../../data/models/low_stock_product_model.dart';
import '../../../data/models/sales_report_model.dart';
import '../../../data/repo/home_repo.dart';
import 'get_home_statistics_states.dart';

class GetHomeStatisticsCubit extends Cubit<GetHomeStatisticsStates>
    with RequestGuardMixin {
  GetHomeStatisticsCubit(this.repo) : super(GetHomeStatisticsInitState());
  HomeRepo? repo;

  HomeStatisticsModel? ordersModel;
  List<InventoryAnalyticsModel> inventoryAnalytics = [];
  List<LowStockProductModel> lowStockProducts = [];
  int? lowStockProductsTotal;
  SalesReportModel? salesReport;

  Future<void> getHomeStatistics({String? status, bool withLoading = true}) async {
    // The dashboard is fired from several places (app start, opening the
    // Orders tab, pull-to-refresh). Guard the whole 4-request chain so an
    // older run can't emit stale data over a newer one.
    final reqId = beginRequest();
    if (withLoading) {
      emit(GetHomeStatisticsLoadingState());
    }

    final statsResult =
        await repo!.getHomeStatistics(cancelToken: requestCancelToken);
    if (!isCurrentRequest(reqId)) return;

    final data = statsResult.fold<HomeStatisticsModel?>((_) => null, (d) => d);
    if (data == null) {
      emit(GetHomeStatisticsErrorState());
      return;
    }

    String? inventoryAnalyticsError;
    String? lowStockProductsError;
    String? salesReportError;

    List<InventoryAnalyticsModel> inventory = [];
    List<LowStockProductModel> lowStock = [];
    int? lowStockTotal;
    SalesReportModel? sales;

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 1, now.day)
        .toIso8601String()
        .split('T')
        .first;
    final endDate = now.toIso8601String().split('T').first;

    final inventoryResult = await repo!
        .getInventoryAnalytics(cancelToken: requestCancelToken);
    if (!isCurrentRequest(reqId)) return;
    inventoryResult.fold(
      (failure) => inventoryAnalyticsError = failure.errMessage,
      (res) => inventory = res.items,
    );

    final lowStockResult = await repo!
        .getLowStockProducts(cancelToken: requestCancelToken);
    if (!isCurrentRequest(reqId)) return;
    lowStockResult.fold(
      (failure) => lowStockProductsError = failure.errMessage,
      (res) {
        lowStock = res.items;
        // The server reports the real total via metadata, so the
        // dashboard badge doesn't need to over-fetch to stay accurate.
        lowStockTotal = res.metadata?.totalItems ?? res.items.length;
      },
    );

    final salesReportResult = await repo!.getSalesReport(
      startDate: startDate,
      endDate: endDate,
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;
    salesReportResult.fold(
      (failure) => salesReportError = failure.errMessage,
      (res) => sales = res,
    );

    // Only now — once every leg of THIS run finished and it's still current —
    // publish the fields and the state, so partial results from an
    // overlapping run can never be mixed in.
    ordersModel = data;
    inventoryAnalytics = inventory;
    lowStockProducts = lowStock;
    lowStockProductsTotal = lowStockTotal;
    salesReport = sales;

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
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}
