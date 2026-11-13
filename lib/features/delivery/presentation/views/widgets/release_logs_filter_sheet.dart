import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/utils/release_type_labels.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_accounts/get_delivery_accounts_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_accounts/get_delivery_accounts_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_release_logs/get_release_logs_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showReleaseLogsFilterSheet({
  required BuildContext context,
  required GetReleaseLogsCubit logsCubit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: logsCubit,
      child: _ReleaseLogsFilterSheet(logsCubit: logsCubit),
    ),
  );
}

class _ReleaseLogsFilterSheet extends StatefulWidget {
  const _ReleaseLogsFilterSheet({required this.logsCubit});

  final GetReleaseLogsCubit logsCubit;

  @override
  State<_ReleaseLogsFilterSheet> createState() =>
      _ReleaseLogsFilterSheetState();
}

class _ReleaseLogsFilterSheetState extends State<_ReleaseLogsFilterSheet> {
  late final orderIdController = TextEditingController(
    text: widget.logsCubit.orderId?.toString(),
  );
  int? selectedCourierId;
  String? selectedReleaseType;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    selectedCourierId = widget.logsCubit.courierId;
    selectedReleaseType = widget.logsCubit.releaseType;
    startDate = DateTime.tryParse(widget.logsCubit.startDate ?? '');
    endDate = DateTime.tryParse(widget.logsCubit.endDate ?? '');
  }

  @override
  void dispose() {
    orderIdController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? startDate : endDate) ?? DateTime.now(),
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

  void _apply() {
    widget.logsCubit.setFilters(
      orderId: int.tryParse(orderIdController.text.trim()),
      courierId: selectedCourierId,
      releaseType: selectedReleaseType,
      startDate: startDate != null ? _fmt(startDate!) : null,
      endDate: endDate != null ? _fmt(endDate!) : null,
    );
    widget.logsCubit.getReleaseLogs(withLoading: true);
    Navigator.of(context).pop();
  }

  void _reset() {
    widget.logsCubit.setFilters();
    widget.logsCubit.getReleaseLogs(withLoading: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetDeliveryAccountsCubit(getIt<DeliveryRepoImpl>())
            ..getDeliveryAccounts(withLoading: true),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
                      controller: orderIdController,
                      textInputType: TextInputType.number,
                      hintText: "order_number".tr(),
                      required: false,
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    Text(
                      "release_type".tr(),
                      style: Styles.inter14500black(context),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    Wrap(
                      spacing: AppConstants.width10(context),
                      runSpacing: AppConstants.height10(context),
                      children: [
                        _Choice(
                          label: "all".tr(),
                          selected: selectedReleaseType == null,
                          onTap: () =>
                              setState(() => selectedReleaseType = null),
                        ),
                        ...releaseTypes.map(
                          (t) => _Choice(
                            label: releaseTypeLabelTr(t),
                            selected: selectedReleaseType == t,
                            onTap: () =>
                                setState(() => selectedReleaseType = t),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),

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
