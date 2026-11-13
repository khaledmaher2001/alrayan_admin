import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/models/remittance_model.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_remittances/get_remittances_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/update_remittance_status/update_remittance_status_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/update_remittance_status/update_remittance_status_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/extra_fields_section.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemittanceItem extends StatelessWidget {
  const RemittanceItem({super.key, required this.remittance});

  final Remittance remittance;

  bool get _isPending => remittance.status == 'pending';

  /// A remittance with no status the server actually sent can't be safely
  /// approved/rejected — the card is shown muted with no action buttons
  /// instead of guessing it's pending.
  bool get _isUnknownStatus => remittance.status == null;

  @override
  Widget build(BuildContext context) {
    final listCubit = context.read<GetRemittancesCubit>();
    return BlocProvider(
      create: (_) => UpdateRemittanceStatusCubit(getIt<DeliveryRepoImpl>()),
      child: Builder(
        builder: (context) =>
            BlocConsumer<UpdateRemittanceStatusCubit, UpdateRemittanceStatusStates>(
              listener: (context, state) {
                if (state is UpdateRemittanceStatusSuccessState) {
                  listCubit.refreshSilently();
                  cherryToast(text: state.message, context: context);
                } else if (state is UpdateRemittanceStatusErrorState) {
                  cherryToast(
                    text: state.errMessage,
                    context: context,
                    isSuccess: false,
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is UpdateRemittanceStatusLoadingState;
                final accentColor = _isUnknownStatus
                    ? DsColor.textMuted
                    : AppColors.primaryColor;
                return Container(
                  padding: EdgeInsets.all(AppConstants.sp15(context)),
                  margin: EdgeInsets.symmetric(
                    horizontal: AppConstants.width20(context),
                  ),
                  decoration: BoxDecoration(
                    color: _isUnknownStatus ? DsColor.page : Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.sp15(context),
                    ),
                    border: Border.all(color: DsColor.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              remittance.courierName != null
                                  ? "${"courier".tr()}: ${remittance.courierName}"
                                  : (remittance.courierId != null
                                        ? "${"courier".tr()}: #${remittance.courierId}"
                                        : '-'),
                              style: Styles.inter14600black(context),
                            ),
                          ),
                          _StatusBadge(status: remittance.status),
                        ],
                      ),
                      SizedBox(height: AppConstants.height10(context)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.width15(context),
                          vertical: AppConstants.height10(context),
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(.08),
                          borderRadius: BorderRadius.circular(
                            AppConstants.sp10(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                AppConstants.sp10(context),
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: accentColor,
                                size: AppConstants.sp20(context),
                              ),
                            ),
                            SizedBox(width: AppConstants.width10(context)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "remittance_amount".tr(),
                                  style: Styles.inter12500Black(
                                    context,
                                  ).copyWith(color: DsColor.textMuted),
                                ),
                                Text(
                                  remittance.amount != null
                                      ? "${remittance.amount!.toStringAsFixed(2)} ${"s_egp".tr()}"
                                      : "-",
                                  style: TextStyle(
                                    fontSize: AppConstants.sp20(context) * 1.1,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (remittance.note != null) ...[
                        SizedBox(height: AppConstants.height10(context)),
                        Text(
                          "${"remittance_note".tr()}: ${remittance.note}",
                          style: Styles.inter12500Black(context),
                        ),
                      ],
                      if (remittance.createdAt != null) ...[
                        SizedBox(height: AppConstants.height5(context)),
                        Text(
                          _formatDateTime(remittance.createdAt),
                          style: Styles.inter10400grey(context),
                        ),
                      ],
                      ExtraFieldsSection(
                        raw: remittance.raw,
                        knownKeys: const {
                          'id',
                          'status',
                          'createdAt',
                          'note',
                          'notes',
                          'reason',
                          'courier',
                          'courierId',
                          'amount',
                          'remittedAmount',
                          'value',
                        },
                      ),
                      if (_isPending) ...[
                        SizedBox(height: AppConstants.height10(context)),
                        Divider(color: DsColor.fill, height: 1),
                        SizedBox(height: AppConstants.height10(context)),
                        if (isLoading)
                          CustomLoadingItem(
                            size: MediaQuery.of(context).size.width * 0.08,
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  label: "approve".tr(),
                                  icon: Icons.check_circle_outline,
                                  color: DsColor.success,
                                  filled: true,
                                  onTap: () => _confirm(context, isApprove: true),
                                ),
                              ),
                              SizedBox(width: AppConstants.width10(context)),
                              Expanded(
                                child: _ActionButton(
                                  label: "reject".tr(),
                                  icon: Icons.cancel_outlined,
                                  color: AppColors.redColor,
                                  filled: false,
                                  onTap: () =>
                                      _confirm(context, isApprove: false),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }

  String _formatDateTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat("yyyy-MM-dd  hh:mm a").format(date);
    } catch (_) {
      return '';
    }
  }

  void _confirm(BuildContext context, {required bool isApprove}) {
    final cubit = context.read<UpdateRemittanceStatusCubit>();
    final color = isApprove ? DsColor.success : AppColors.redColor;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isApprove
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: color,
                    size: MediaQuery.of(context).size.width * .08,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              isApprove
                  ? "confirm_approve_remittance_title".tr()
                  : "confirm_reject_remittance_title".tr(),
              textAlign: TextAlign.center,
              style: Styles.inter16500black(context),
            ),
            SizedBox(height: AppConstants.height5(context)),
            Text(
              isApprove
                  ? "confirm_approve_remittance_message".tr()
                  : "confirm_reject_remittance_message".tr(),
              style: Styles.inter14500black(
                context,
              ).copyWith(color: DsColor.text2),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DsColor.page,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DsColor.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: DsColor.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${"remittance_amount".tr()}: ${remittance.amount != null ? remittance.amount!.toStringAsFixed(2) : '-'} ${"s_egp".tr()}",
                      style: Styles.inter14500black(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppConstants.height20(context)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      if (isApprove) {
                        cubit.approve(remittance.id!);
                      } else {
                        cubit.reject(remittance.id!);
                      }
                    },
                    child: Text(
                      isApprove ? "approve".tr() : "reject".tr(),
                      style: Styles.inter16500black(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    "cancel".tr(),
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: DsColor.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case 'pending':
        color = DsColor.warning;
        label = "remittance_status_pending".tr();
        break;
      case 'approved':
        color = DsColor.success;
        label = "remittance_status_approved".tr();
        break;
      case 'rejected':
        color = DsColor.danger;
        label = "remittance_status_rejected".tr();
        break;
      default:
        color = DsColor.textMuted;
        label = "remittance_status_unknown".tr();
    }
    // Same dot + text on a faint tint as every other status in the app.
    final bg = color == DsColor.warning ? DsColor.warningBg : color == DsColor.success ? DsColor.successBg : color == DsColor.textMuted ? DsColor.fill : DsColor.dangerBg;
    return DsStatusBadge(status: null, label: label, fg: color, bg: bg);
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor = filled ? Colors.white : color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.height10(context) / 1.5,
        ),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
          border: Border.all(color: color.withOpacity(.4)),
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
                style: TextStyle(
                  fontSize: AppConstants.sp15(context),
                  color: contentColor,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
