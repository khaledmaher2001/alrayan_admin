import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_payment_labels.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_status_ui.dart';
import 'package:alrayan_admin/features/orders/presentation/view/order_details_view.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/cancel_order_dialog.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/reopen_order_dialog.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/cancel_order/cancel_order_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/cancel_order/cancel_order_states.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_awaiting_customer_orders/get_awaiting_customer_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/reopen_order/reopen_order_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/reopen_order/reopen_order_states.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AwaitingCustomerOrderItem extends StatelessWidget {
  const AwaitingCustomerOrderItem({super.key, required this.order});

  final Items order;

  @override
  Widget build(BuildContext context) {
    final listCubit = context.read<GetAwaitingCustomerOrdersCubit>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ReopenOrderCubit(getIt<OrdersRepoImpl>())),
        BlocProvider(create: (_) => CancelOrderCubit(getIt<OrdersRepoImpl>())),
      ],
      child: Builder(
        builder: (context) => MultiBlocListener(
          listeners: [
            BlocListener<ReopenOrderCubit, ReopenOrderStates>(
              listener: (context, state) {
                if (state is ReopenOrderSuccessState) {
                  cherryToast(
                    text: "s_the_order_was_reopened_and_made_avai".tr(),
                    context: context,
                  );
                  listCubit.removeOrderLocally(order.id!);
                  listCubit.refreshSilently();
                } else if (state is ReopenOrderErrorState) {
                  cherryToast(
                    text: state.error,
                    isSuccess: false,
                    context: context,
                  );
                }
              },
            ),
            BlocListener<CancelOrderCubit, CancelOrderStates>(
              listener: (context, state) {
                if (state is CancelOrderSuccessState) {
                  cherryToast(text: "s_order_cancelled".tr(), context: context);
                  // The order may have been paid electronically — surface the
                  // backend's own message (refund status) instead of assuming
                  // the amount was refunded automatically.
                  final isElectronicPayment =
                      (order.paymentMethod ?? 'cash_on_delivery') !=
                      'cash_on_delivery';
                  if (isElectronicPayment &&
                      state.message.trim().isNotEmpty &&
                      state.message.trim() != "s_order_cancelled".tr()) {
                    cherryToast(text: state.message, context: context);
                  }
                  listCubit.removeOrderLocally(order.id!);
                  listCubit.refreshSilently();
                } else if (state is CancelOrderErrorState) {
                  cherryToast(
                    text: state.error,
                    isSuccess: false,
                    context: context,
                  );
                }
              },
            ),
          ],
          child: _Card(order: order),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.order});

  final Items order;

  DateTime? get _releasedAt {
    final raw = order.releasedAt ?? order.updatedAt;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  String _elapsedSince(DateTime from) {
    final d = DateTime.now().difference(from);
    if (d.isNegative) return "s_now".tr();
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    if (days > 0) return "${"i_dur_days".tr(namedArgs: {"a": "$days"})}${hours > 0 ? "${"i_dur_and".tr()}${"i_dur_hours".tr(namedArgs: {"a": "$hours"})}" : ""}";
    if (hours > 0) {
      return "${"i_dur_hours".tr(namedArgs: {"a": "$hours"})}${minutes > 0 ? "${"i_dur_and".tr()}${"i_dur_minutes".tr(namedArgs: {"a": "$minutes"})}" : ""}";
    }
    return "i_x_min_68".tr(namedArgs: {"a": "${minutes}"});
  }

  @override
  Widget build(BuildContext context) {
    final address = order.shippingAddress;
    final customerName = address?.user?.fullName;
    final phone = (address?.phone1 ?? '').isNotEmpty
        ? address!.phone1
        : (address?.phone2 ?? '').isNotEmpty
        ? address!.phone2
        : order.shippingAddress?.user?.phoneNumber;
    final statusColor = AppConstants.getStatusColor(order.status ?? '');
    final statusTextColor = AppConstants.getTextColor(order.status ?? '');
    final releasedAt = _releasedAt;

    return Container(
      margin: EdgeInsetsDirectional.symmetric(
        horizontal: AppConstants.width15(context),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        color: Colors.white,
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: statusTextColor),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: AppConstants.width15(context),
                  vertical: AppConstants.height15(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "s_order_number".tr(),
                                style: Styles.inter14500black(context).copyWith(
                                  color: const Color(0xff9CA4AB),
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(
                                height: AppConstants.height5(context) / 2,
                              ),
                              Text(
                                order.orderNumber ?? '-',
                                style: Styles.inter16500black(
                                  context,
                                ).copyWith(letterSpacing: 0.6),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.width10(context),
                            vertical: AppConstants.height5(context) / 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(
                              AppConstants.sp30(context) * 3,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppConstants.getStatusText(order.status ?? ''),
                                style: Styles.inter14500black(
                                  context,
                                ).copyWith(color: statusTextColor),
                              ),
                              SizedBox(width: AppConstants.width5(context)),
                              Icon(
                                OrderStatusUi.icon(order.status),
                                size: 14,
                                color: statusTextColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                    Divider(height: 1, color: DsColor.border),
                    SizedBox(height: AppConstants.height10(context)),

                    _InfoLine(label: "s_customer_name".tr(), value: customerName ?? '-'),
                    SizedBox(height: AppConstants.height5(context)),
                    _InfoLine(label: "s_phone_number".tr(), value: phone ?? '-'),
                    SizedBox(height: AppConstants.height5(context)),
                    _InfoLine(
                      label: "s_address".tr(),
                      value:
                          [address?.title, address?.description]
                              .where((e) => (e ?? '').isNotEmpty)
                              .join(" - ")
                              .isEmpty
                          ? '-'
                          : [
                              address?.title,
                              address?.description,
                            ].where((e) => (e ?? '').isNotEmpty).join(" - "),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    _InfoLine(
                      label: "s_order_total".tr(),
                      value: "${order.totalAmount ?? '-'} ج.م",
                      valueColor: AppColors.primaryColor,
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    _InfoLine(
                      label: "s_payment_method".tr(),
                      value: paymentMethodLabel(order.paymentMethod),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    _InfoLine(
                      label: "s_courier_2".tr(),
                      value:
                          order.previousCourierName ??
                          order.deliveryUser?.fullName ??
                          "s_unavailable".tr(),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    _InfoLine(
                      label: "s_reason_delivery_failed".tr(),
                      value: order.releaseReason ?? "s_unavailable".tr(),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    _InfoLine(
                      label: "s_released_at".tr(),
                      value: releasedAt != null
                          ? DateFormat("yyyy-MM-dd  hh:mm a").format(releasedAt)
                          : "s_unavailable".tr(),
                    ),
                    if (releasedAt != null) ...[
                      SizedBox(height: AppConstants.height5(context)),
                      _InfoLine(
                        label: "s_time_since_release".tr(),
                        value: _elapsedSince(releasedAt),
                      ),
                    ],

                    SizedBox(height: AppConstants.height15(context)),
                    _Actions(order: order, phone: phone),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Styles.inter14500black(
              context,
            ).copyWith(color: const Color(0xff9CA4AB)),
          ),
        ),
        SizedBox(width: AppConstants.width10(context)),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Styles.inter14600black(context).copyWith(color: valueColor),
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.order, required this.phone});

  final Items order;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final reopenState = context.watch<ReopenOrderCubit>().state;
    final cancelState = context.watch<CancelOrderCubit>().state;
    final isReopening = reopenState is ReopenOrderLoadingState;
    final isCancelling = cancelState is CancelOrderLoadingState;
    final busy = isReopening || isCancelling;

    return Column(
      children: [
        Row(
          children: [
            if ((phone ?? '').isNotEmpty) ...[
              Expanded(
                child: _ActionButton(
                  label: "s_call_the_customer".tr(),
                  icon: Icons.call_rounded,
                  color: AppColors.secondaryColor,
                  filled: false,
                  onTap: () => launchUrlString("tel:$phone"),
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
            ],
            Expanded(
              child: _ActionButton(
                label: "s_view_details".tr(),
                icon: Icons.receipt_long_rounded,
                color: AppColors.primaryColor,
                filled: false,
                onTap: () => NavigationUtils.navigateTo(
                  context: context,
                  destinationScreen: OrderDetailsView(orderData: order),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.height10(context)),
        Row(
          children: [
            Expanded(
              child: isReopening
                  ? const CustomLoadingItem()
                  : _ActionButton(
                      label: "s_reopen_order".tr(),
                      icon: Icons.lock_open_rounded,
                      color: AppColors.primaryColor,
                      filled: true,
                      onTap: busy
                          ? null
                          : () => showReopenOrderDialog(
                              context: context,
                              onConfirm: () => context
                                  .read<ReopenOrderCubit>()
                                  .reopenOrder(orderId: order.id!),
                            ),
                    ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Expanded(
              child: isCancelling
                  ? const CustomLoadingItem()
                  : _ActionButton(
                      label: "s_cancel_order".tr(),
                      icon: Icons.cancel_outlined,
                      color: AppColors.redColor,
                      filled: false,
                      onTap: busy
                          ? null
                          : () => showCancelOrderDialog(
                              context: context,
                              onConfirm: (reason) =>
                                  context.read<CancelOrderCubit>().cancelOrder(
                                    orderId: order.id!,
                                    data: {"reason": reason},
                                  ),
                            ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor = filled ? Colors.white : color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppConstants.height10(context),
            horizontal: AppConstants.width10(context),
          ),
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
            border: Border.all(color: color.withValues(alpha: .5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppConstants.sp15(context), color: contentColor),
              SizedBox(width: AppConstants.width5(context)),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.inter12500Black(
                    context,
                  ).copyWith(color: contentColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
