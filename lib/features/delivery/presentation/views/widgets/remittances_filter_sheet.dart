import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_accounts/get_delivery_accounts_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_accounts/get_delivery_accounts_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_remittances/get_remittances_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showRemittancesFilterSheet({
  required BuildContext context,
  required GetRemittancesCubit remittancesCubit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: remittancesCubit,
      child: _RemittancesFilterSheet(remittancesCubit: remittancesCubit),
    ),
  );
}

class _RemittancesFilterSheet extends StatefulWidget {
  const _RemittancesFilterSheet({required this.remittancesCubit});

  final GetRemittancesCubit remittancesCubit;

  @override
  State<_RemittancesFilterSheet> createState() =>
      _RemittancesFilterSheetState();
}

class _RemittancesFilterSheetState extends State<_RemittancesFilterSheet> {
  static const _statuses = ['pending', 'approved', 'rejected'];

  String? selectedStatus;
  int? selectedCourierId;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.remittancesCubit.status;
    selectedCourierId = widget.remittancesCubit.courierId;
  }

  void _apply() {
    widget.remittancesCubit.setFilters(
      status: selectedStatus,
      courierId: selectedCourierId,
    );
    widget.remittancesCubit.getRemittances(withLoading: true);
    Navigator.of(context).pop();
  }

  void _reset() {
    widget.remittancesCubit.setFilters(status: null, courierId: null);
    widget.remittancesCubit.getRemittances(withLoading: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetDeliveryAccountsCubit(getIt<DeliveryRepoImpl>())
            ..getDeliveryAccounts(withLoading: true),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                    Text(
                      "remittance_status".tr(),
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
                          onTap: () =>
                              setState(() => selectedStatus = null),
                        ),
                        ..._statuses.map(
                          (s) => _Choice(
                            label: "remittance_status_$s".tr(),
                            selected: selectedStatus == s,
                            onTap: () => setState(() => selectedStatus = s),
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
