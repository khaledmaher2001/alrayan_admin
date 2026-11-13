import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_accounts/get_delivery_accounts_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_accounts/get_delivery_accounts_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_orders/get_delivery_orders_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_order_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _orderStatuses = [
  'pending',
  'confirmed',
  'shipped',
  'delivered',
  'cancelled',
  'refunded',
];
const _paymentStatuses = ['pending', 'paid', 'failed', 'refunded'];
const _deliveryStages = [
  'assigned',
  'arrived_at_store',
  'picked_up',
  'on_the_way',
  'delivered',
];

Future<void> showDeliveryOrdersFilterSheet({
  required BuildContext context,
  required GetDeliveryOrdersCubit ordersCubit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: ordersCubit,
      child: _DeliveryOrdersFilterSheet(ordersCubit: ordersCubit),
    ),
  );
}

class _DeliveryOrdersFilterSheet extends StatefulWidget {
  const _DeliveryOrdersFilterSheet({required this.ordersCubit});

  final GetDeliveryOrdersCubit ordersCubit;

  @override
  State<_DeliveryOrdersFilterSheet> createState() =>
      _DeliveryOrdersFilterSheetState();
}

class _DeliveryOrdersFilterSheetState
    extends State<_DeliveryOrdersFilterSheet> {
  late final orderNumberController = TextEditingController(
    text: widget.ordersCubit.filters['orderNumber'] as String?,
  );
  int? selectedCourierId;
  bool unassignedOnly = false;
  String? selectedStatus;
  String? selectedPaymentStatus;
  bool? finishedFilter;
  DateTime? startDate;
  DateTime? endDate;
  String? selectedStage;

  @override
  void initState() {
    super.initState();
    final filters = widget.ordersCubit.filters;
    selectedCourierId = filters['deliveryUserId'] as int?;
    unassignedOnly = filters['unassigned'] == 'true';
    selectedStatus = filters['status'] as String?;
    selectedPaymentStatus = filters['paymentStatus'] as String?;
    if (filters['finished'] == 'true') finishedFilter = true;
    if (filters['finished'] == 'false') finishedFilter = false;
    selectedStage = widget.ordersCubit.clientDeliveryStageFilter;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        startDate = picked;
      } else {
        endDate = picked;
      }
    });
  }

  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  void _apply() {
    widget.ordersCubit.setFilters({
      if (orderNumberController.text.trim().isNotEmpty)
        'orderNumber': orderNumberController.text.trim(),
      if (selectedCourierId != null && !unassignedOnly)
        'deliveryUserId': selectedCourierId,
      if (unassignedOnly) 'unassigned': 'true',
      if (selectedStatus != null) 'status': selectedStatus,
      if (selectedPaymentStatus != null) 'paymentStatus': selectedPaymentStatus,
      if (startDate != null) 'startDate': _fmt(startDate!),
      if (endDate != null) 'endDate': _fmt(endDate!),
      if (finishedFilter != null)
        'finished': finishedFilter! ? 'true' : 'false',
    });
    widget.ordersCubit.clientDeliveryStageFilter = selectedStage;
    widget.ordersCubit.getDeliveryOrders(withLoading: true);
    Navigator.of(context).pop();
  }

  void _reset() {
    widget.ordersCubit.setFilters({});
    widget.ordersCubit.clientDeliveryStageFilter = null;
    widget.ordersCubit.getDeliveryOrders(withLoading: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetDeliveryAccountsCubit(getIt<DeliveryRepoImpl>())
            ..getDeliveryAccounts(withLoading: true),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            SizedBox(height: AppConstants.height15(context)),
            Center(
              child: Container(
                height: AppConstants.height5(context),
                width: MediaQuery.of(context).size.width * 0.15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.sp10(context),
                  ),
                  color: DsColor.border,
                ),
              ),
            ),
            SizedBox(height: AppConstants.height15(context)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: Row(
                children: [
                  Text("filters".tr(), style: Styles.inter16500black(context)),
                  const Spacer(),
                  TextButton(
                    onPressed: _reset,
                    child: Text("reset_filters".tr()),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Divider(color: DsColor.fill),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.width20(context),
                  vertical: AppConstants.height15(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextFormField(
                      controller: orderNumberController,
                      textInputType: TextInputType.text,
                      hintText: "order_number".tr(),
                      required: false,
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    Text(
                      "unassigned_only".tr(),
                      style: Styles.inter14500black(context),
                    ),
                    Switch(
                      value: unassignedOnly,
                      activeColor: AppColors.primaryColor,
                      onChanged: (value) =>
                          setState(() => unassignedOnly = value),
                    ),
                    SizedBox(height: AppConstants.height10(context)),

                    if (!unassignedOnly) ...[
                      Text(
                        "delivery_courier".tr(),
                        style: Styles.inter14500black(context),
                      ),
                      SizedBox(height: AppConstants.height5(context)),
                      BlocBuilder<
                        GetDeliveryAccountsCubit,
                        GetDeliveryAccountsStates
                      >(
                        builder: (context, state) {
                          final accounts = context
                              .read<GetDeliveryAccountsCubit>()
                              .accountsList;
                          return Wrap(
                            spacing: AppConstants.width10(context),
                            runSpacing: AppConstants.height10(context),
                            children: [
                              _Choice(
                                label: "all".tr(),
                                selected: selectedCourierId == null,
                                onTap: () =>
                                    setState(() => selectedCourierId = null),
                              ),
                              ...accounts.map(
                                (a) => _Choice(
                                  label: a.fullName.isNotEmpty
                                      ? a.fullName
                                      : '#${a.userId}',
                                  selected: selectedCourierId == a.userId,
                                  onTap: () => setState(
                                    () => selectedCourierId = a.userId,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: AppConstants.height15(context)),
                    ],

                    Text(
                      "order_status".tr(),
                      style: Styles.inter14500black(context),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    Wrap(
                      spacing: AppConstants.width10(context),
                      runSpacing: AppConstants.height10(context),
                      children: [
                        _Choice(
                          label: "all".tr(),
                          selected: selectedStatus == null,
                          onTap: () => setState(() => selectedStatus = null),
                        ),
                        ..._orderStatuses.map(
                          (s) => _Choice(
                            label: "order_status_$s".tr(),
                            selected: selectedStatus == s,
                            onTap: () => setState(() => selectedStatus = s),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    Text(
                      "payment_status".tr(),
                      style: Styles.inter14500black(context),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    Wrap(
                      spacing: AppConstants.width10(context),
                      runSpacing: AppConstants.height10(context),
                      children: [
                        _Choice(
                          label: "all".tr(),
                          selected: selectedPaymentStatus == null,
                          onTap: () =>
                              setState(() => selectedPaymentStatus = null),
                        ),
                        ..._paymentStatuses.map(
                          (s) => _Choice(
                            label: "payment_status_$s".tr(),
                            selected: selectedPaymentStatus == s,
                            onTap: () =>
                                setState(() => selectedPaymentStatus = s),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    Text(
                      "finished_or_ongoing".tr(),
                      style: Styles.inter14500black(context),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    Wrap(
                      spacing: AppConstants.width10(context),
                      runSpacing: AppConstants.height10(context),
                      children: [
                        _Choice(
                          label: "all".tr(),
                          selected: finishedFilter == null,
                          onTap: () => setState(() => finishedFilter = null),
                        ),
                        _Choice(
                          label: "ongoing_orders".tr(),
                          selected: finishedFilter == false,
                          onTap: () => setState(() => finishedFilter = false),
                        ),
                        _Choice(
                          label: "finished_orders".tr(),
                          selected: finishedFilter == true,
                          onTap: () => setState(() => finishedFilter = true),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    Row(
                      children: [
                        Text(
                          "delivery_stage".tr(),
                          style: Styles.inter14500black(context),
                        ),
                        SizedBox(width: AppConstants.width5(context)),
                        Tooltip(
                          message: "delivery_stage_filter_note".tr(),
                          child: Icon(
                            Icons.info_outline,
                            size: AppConstants.sp15(context),
                            color: DsColor.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "delivery_stage_filter_note".tr(),
                      style: Styles.inter10400grey(context),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    Wrap(
                      spacing: AppConstants.width10(context),
                      runSpacing: AppConstants.height10(context),
                      children: [
                        _Choice(
                          label: "all".tr(),
                          selected: selectedStage == null,
                          onTap: () => setState(() => selectedStage = null),
                        ),
                        ..._deliveryStages.map(
                          (s) => _Choice(
                            label: deliveryStageLabel(s),
                            selected: selectedStage == s,
                            onTap: () => setState(() => selectedStage = s),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(isStart: true),
                            child: Text(
                              startDate != null
                                  ? _fmt(startDate!)
                                  : "start_date".tr(),
                            ),
                          ),
                        ),
                        SizedBox(width: AppConstants.width10(context)),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(isStart: false),
                            child: Text(
                              endDate != null
                                  ? _fmt(endDate!)
                                  : "end_date".tr(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppConstants.width20(context)),
              child: DefaultButton(
                onPress: _apply,
                text: "apply_filters".tr(),
                borderRadius: AppConstants.sp10(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width15(context),
          vertical: AppConstants.height5(context),
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.primaryColor : DsColor.textSubtle,
          ),
          borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
        ),
        child: Text(
          label,
          style: Styles.inter14500black(
            context,
          ).copyWith(color: selected ? Colors.white : DsColor.text2),
        ),
      ),
    );
  }
}
