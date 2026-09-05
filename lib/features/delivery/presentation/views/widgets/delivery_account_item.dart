import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/models/delivery_account_model.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/delete_delivery_account/delete_delivery_account_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/delete_delivery_account/delete_delivery_account_state.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_accounts/get_delivery_accounts_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_account_details_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_account_form_sheet.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryAccountItem extends StatelessWidget {
  const DeliveryAccountItem({super.key, required this.account});

  final DeliveryAccount account;

  @override
  Widget build(BuildContext context) {
    final isAvailable = account.isAvailableForDelivery;
    return GestureDetector(
      onTap: () => NavigationUtils.navigateTo(
        context: context,
        destinationScreen: DeliveryAccountDetailsView(account: account),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
          border: Border.all(color: const Color(0xffE3E7EC)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(AppConstants.sp15(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(name: account.fullName),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.fullName.isNotEmpty ? account.fullName : "-",
                          style: Styles.inter16500black(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (account.email.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: AppConstants.height5(context) / 2),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                account.email,
                                textAlign: TextAlign.right,
                                style: Styles.inter12500Black(context).copyWith(color: const Color(0xff9CA4AB)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        if (account.phoneNumber.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: AppConstants.height5(context) / 2),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                account.phoneNumber,
                                textAlign: TextAlign.right,
                                style: Styles.inter12500Black(context).copyWith(color: const Color(0xff9CA4AB)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isAvailable != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.width10(context),
                        vertical: AppConstants.height5(context) / 2,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable ? const Color(0xff22C55E) : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                      ),
                      child: Text(
                        isAvailable ? "courier_available".tr() : "courier_unavailable".tr(),
                        style: Styles.inter12500Black(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppConstants.height15(context)),
              Divider(color: Colors.grey.shade100, height: 1),
              SizedBox(height: AppConstants.height15(context)),
              Row(
                children: [
                  _RoundedIconBox(icon: Icons.two_wheeler_rounded),
                  Expanded(
                    child: _StatColumn(
                      label: "vehicle_name".tr(),
                      value: account.vehicleName?.isNotEmpty == true ? account.vehicleName! : "-",
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: "vehicle_plate_number".tr(),
                      value: account.vehiclePlateNumber?.isNotEmpty == true ? account.vehiclePlateNumber! : "-",
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.height15(context)),
              Divider(color: Colors.grey.shade100, height: 1),
              SizedBox(height: AppConstants.height15(context)),
              Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      label: "earning_percentage".tr(),
                      value: account.earningPercentage != null ? "${account.earningPercentage}%" : "-",
                      valueColor: AppColors.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: "max_active_orders".tr(),
                      value: account.maxActiveOrdersOverride?.toString() ?? "-",
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: "wallet_balance".tr(),
                      value: account.walletBalance != null ? "${account.walletBalance} ج.م" : "-",
                    ),
                  ),
                ],
              ),
              if (account.createdAt != null) ...[
                SizedBox(height: AppConstants.height10(context)),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    _formatDate(account.createdAt),
                    style: Styles.inter10400grey(context),
                  ),
                ),
              ],
              SizedBox(height: AppConstants.height10(context)),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: "view".tr(),
                      icon: Icons.visibility_outlined,
                      style: _ActionButtonStyle.filled,
                      onTap: () => NavigationUtils.navigateTo(
                        context: context,
                        destinationScreen: DeliveryAccountDetailsView(account: account),
                      ),
                    ),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: _ActionButton(
                      label: "edit".tr(),
                      icon: Icons.edit_outlined,
                      style: _ActionButtonStyle.outlined,
                      onTap: () {
                        final listCubit = context.read<GetDeliveryAccountsCubit>();
                        showDeliveryAccountFormSheet(
                          context: context,
                          account: account,
                          onSuccess: () => listCubit.getDeliveryAccounts(withLoading: true),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: _ActionButton(
                      label: "delete".tr(),
                      icon: Icons.delete_outline_rounded,
                      style: _ActionButtonStyle.danger,
                      onTap: () => _confirmDelete(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      return DateFormat("yyyy-MM-dd").format(DateTime.parse(isoDate).toLocal());
    } catch (_) {
      return '';
    }
  }

  void _confirmDelete(BuildContext context) {
    final listCubit = context.read<GetDeliveryAccountsCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<DeleteDeliveryAccountCubit>(),
        child:
            BlocConsumer<
              DeleteDeliveryAccountCubit,
              DeleteDeliveryAccountState
            >(
              listener: (ctx, state) {
                if (state is DeleteDeliveryAccountSuccess) {
                  Navigator.of(dialogContext).pop();
                  listCubit.removeAccount(account.userId!);
                  cherryToast(
                    text: "courier_deleted_success".tr(),
                    context: context,
                  );
                } else if (state is DeleteDeliveryAccountError) {
                  Navigator.of(dialogContext).pop();
                  cherryToast(
                    text: state.message,
                    context: context,
                    isSuccess: false,
                  );
                }
              },
              builder: (ctx, state) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red.shade400,
                            size: MediaQuery.of(context).size.width * .08,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            "delete_courier_title".tr(),
                            textAlign: TextAlign.center,
                            style: Styles.inter16500black(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    Text(
                      "delete_courier_message".tr(),
                      style: Styles.inter14500black(
                        context,
                      ).copyWith(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: Colors.grey.shade500,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              account.fullName.isNotEmpty
                                  ? account.fullName
                                  : "-",
                              style: Styles.inter14500black(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "cannot_undo_action".tr(),
                      style: Styles.inter14500black(
                        context,
                      ).copyWith(color: Colors.red.shade400),
                    ),
                    SizedBox(height: AppConstants.height20(context)),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: state is DeleteDeliveryAccountLoading
                                ? null
                                : () => ctx
                                      .read<DeleteDeliveryAccountCubit>()
                                      .deleteDeliveryAccount(account.userId!),
                            child: state is DeleteDeliveryAccountLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "delete".tr(),
                                    style: Styles.inter16500black(
                                      context,
                                    ).copyWith(color: Colors.white),
                                  ),
                          ),
                        ),
                        TextButton(
                          onPressed: state is DeleteDeliveryAccountLoading
                              ? null
                              : () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            "cancel".tr(),
                            style: Styles.inter16500black(
                              context,
                            ).copyWith(color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * .13;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: Styles.inter16500black(context).copyWith(color: Colors.white),
        ),
      ),
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }
}

/// أيقونة دائرية داكنة صغيرة، تُستخدم كأيقونة سياقية (المركبة هنا) داخل
/// بطاقة المندوب.
class _RoundedIconBox extends StatelessWidget {
  const _RoundedIconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * .1;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Styles.inter12500Black(context).copyWith(color: const Color(0xff9CA4AB)),
        ),
        SizedBox(height: AppConstants.height5(context) / 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: Styles.inter16500black(context).copyWith(color: valueColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

enum _ActionButtonStyle { filled, outlined, danger }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.style,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final _ActionButtonStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final Color? border;
    switch (style) {
      case _ActionButtonStyle.filled:
        bg = AppColors.secondaryColor;
        fg = Colors.white;
        border = null;
      case _ActionButtonStyle.outlined:
        bg = Colors.white;
        fg = const Color(0xff0F0F0E);
        border = const Color(0xffE3E7EC);
      case _ActionButtonStyle.danger:
        bg = AppColors.primaryColor.shade50;
        fg = AppColors.primaryColor;
        border = null;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context) / 1.2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: border != null ? Border.all(color: border) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppConstants.sp15(context), color: fg),
            SizedBox(width: AppConstants.width5(context)),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppConstants.sp15(context),
                  color: fg,
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
