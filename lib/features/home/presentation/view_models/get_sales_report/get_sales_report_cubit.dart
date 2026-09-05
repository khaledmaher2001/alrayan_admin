import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/home/data/repo/home_repo.dart';
import 'get_sales_report_state.dart';

class GetSalesReportCubit extends Cubit<GetSalesReportState> {
  GetSalesReportCubit(this.repo) : super(GetSalesReportInitial());

  final HomeRepo repo;

  Future<void> getSalesReport({
    required String startDate,
    required String endDate,
    String type = '',
  }) async {
    emit(GetSalesReportLoading());
    final result = await repo.getSalesReport(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
    result.fold(
      (failure) => emit(GetSalesReportError(failure.errMessage)),
      (data) => emit(GetSalesReportSuccess(data)),
    );
  }
}
