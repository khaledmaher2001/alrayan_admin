import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/repo/order_finance_repo.dart';

abstract class OrderFinanceState {}

class OrderFinanceLoading extends OrderFinanceState {}

class OrderFinanceReady extends OrderFinanceState {
  final List<OrderReturnModel> returns;
  final bool busy;
  final String? message; // one-shot success text
  final String? error; // one-shot error text
  OrderFinanceReady(this.returns, {this.busy = false, this.message, this.error});
}

/// Returns list + collection / return / refund actions of one order.
/// [onChanged] lets the details screen reload the order (amounts, status).
class OrderFinanceCubit extends Cubit<OrderFinanceState> {
  OrderFinanceCubit(this.repo, this.orderId, {this.onChanged}) : super(OrderFinanceLoading());

  final OrderFinanceRepo repo;
  final int orderId;
  final void Function()? onChanged;
  List<OrderReturnModel> _returns = [];

  /// A fresh key per user action: retries of the same request can't record twice.
  static String newKey() => '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

  Future<void> load() async {
    final r = await repo.getReturns(orderId);
    r.fold((f) => emit(OrderFinanceReady(_returns, error: f.errMessage)), (list) {
      _returns = list;
      emit(OrderFinanceReady(list));
    });
  }

  Future<void> _act(Future<Either<Failure, String>> Function() action) async {
    emit(OrderFinanceReady(_returns, busy: true));
    final r = await action();
    await r.fold((f) async => emit(OrderFinanceReady(_returns, error: f.errMessage)), (msg) async {
      final fresh = await repo.getReturns(orderId);
      fresh.fold((_) {}, (list) => _returns = list);
      emit(OrderFinanceReady(_returns, message: msg));
      onChanged?.call();
    });
  }

  Future<void> collect({double? amount}) => _act(() => repo.collect(orderId, amount: amount, key: newKey()));

  Future<void> createReturn({required List<Map<String, dynamic>> items, required bool refundCash, bool includeDeliveryFee = false, String? note}) =>
      _act(() => repo.createReturn(orderId, items: items, refundCash: refundCash, includeDeliveryFee: includeDeliveryFee, note: note, key: newKey()));

  Future<void> confirmRefund(int returnId, {String? reference}) => _act(() => repo.settleRefund(returnId, completed: true, reference: reference));

  Future<void> failRefund(int returnId, String reason) => _act(() => repo.settleRefund(returnId, completed: false, reason: reason));
}
