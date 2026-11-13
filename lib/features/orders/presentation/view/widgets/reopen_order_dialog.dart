import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:flutter/material.dart';

/// Confirmation dialog shown before `PATCH /orders/:id/reopen`.
/// [onConfirm] runs after the admin taps "إعادة فتح".
Future<void> showReopenOrderDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
}) {
  return showDialog(
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
                  color: AppColors.primaryColor.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_open_rounded,
                  size: MediaQuery.of(context).size.width * .08,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Text(
            "s_reopen_order".tr(),
            textAlign: TextAlign.center,
            style: Styles.inter16500black(context),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Text(
            "s_the_order_will_be_made_available_to_".tr(),
            style: Styles.inter14500black(
              context,
            ).copyWith(color: DsColor.text2),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onConfirm();
                  },
                  child: Text(
                    "s_reopen".tr(),
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  "s_back_2".tr(),
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
