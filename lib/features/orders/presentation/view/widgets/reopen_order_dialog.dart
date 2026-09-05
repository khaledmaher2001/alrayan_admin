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
            "إعادة فتح الطلب",
            textAlign: TextAlign.center,
            style: Styles.inter16500black(context),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Text(
            "سيتم إتاحة الطلب مرة أخرى لعمال التوصيل. هل أنت متأكد؟",
            style: Styles.inter14500black(
              context,
            ).copyWith(color: Colors.grey.shade700),
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
                    "إعادة فتح",
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  "رجوع",
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
  );
}
